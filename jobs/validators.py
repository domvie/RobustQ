from django.core.validators import ValidationError
import libsbml
from django.db.models.fields.files import FieldFile, FileField
from django.core.files.uploadedfile import InMemoryUploadedFile
import cobra
import os


def sbml_validator(value):
    """
    Validates the uploaded SBML/XML file using the libSBML library
    :param value: FileField/FieldFile object
    :return: FileField object or ValidationError
    """
    if os.path.splitext(value.name)[1] == '.json':  # no support for JSON validation!
        return
    try:
        reader = libsbml.SBMLReader()
        if isinstance(value, FileField):
            document = reader.readSBML(value.name)
            cobraval = cobra.io.validate_sbml_model(value.name)
        elif isinstance(value, FieldFile):
            if isinstance(value.file, InMemoryUploadedFile):
                # if the uploaded file size is smaller than ~2.5MB, Django saves the file in memory
                document = reader.readSBML(value.name)
                # 2nd validation with cobra
                cobraval = cobra.io.validate_sbml_model(value.name)

            else:
                # file size > 2.5MB: file not saved in memory but at a temporary upload path
                document = reader.readSBML(value.file.temporary_file_path())
                # 2nd validation with cobra
                cobraval = cobra.io.validate_sbml_model(value.file.temporary_file_path())

        else:
            document = reader.readSBML(value.name)
            cobraval = cobra.io.validate_sbml_model(value.name)

        nr_errors = document.getNumErrors()
        if nr_errors:
            errors = []
            for err in range(nr_errors):
                error = document.getError(err)
                msg = error.getMessage()
                line = error.getLine()
                # severity = error.getSeverityAsString()
                category = error.getCategoryAsString()
                errors.append(f'{category}/line {line}: {msg}')
            raise ValidationError(message=errors, code='sbml_file_error', params={'error': msg, 'line': line})

        # cobra validation
        if cobraval[0] is None:
            raise ValidationError(message=cobraval[1]['COBRA_FATAL'], code='sbml_file_error',
                                  params={'error':cobraval[1]['SBML_ERROR'], 'line': '?'})

        return value
    except Exception as e:
        raise ValidationError(message=e.args[0], code='sbml_validation_exception',
                              params={'error':e.args[0], 'line': '?'})