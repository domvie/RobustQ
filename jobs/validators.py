from django.core.validators import ValidationError
import libsbml
from django.conf import settings


def sbml_validator(value):
    """
    Validates the uploaded SBML/XML file using the libSBML library
    :param value: FileField/FieldFile object
    :return: FileField object or ValidationError
    """
    try:
        reader = libsbml.SBMLReader()
        document = reader.readSBML(value.name)
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
        return value
    # except TypeError as te:
    #     print(te.args)
    #     return value
    except Exception as e:
        raise ValidationError(message=e.args[0], code='sbml_validation_exception',
                              params={'error':e.args[0], 'line': '?'})