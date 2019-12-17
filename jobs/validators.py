from django.core.validators import ValidationError
import libsbml
from django.conf import settings


def sbml_validator(value):
    """
    Validates the uploaded SBML/XML file using the libSBML library
    :param value: FileField object
    :return: FileField object or ValidationError
    """
    print(value.path)
    try:
        reader = libsbml.SBMLReader()
        document = reader.readSBML(value.path)
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
    except TypeError as te:
        print(te.args[1])
        return value
    except Exception as e:
        print(e.args[1])
        raise ValidationError(message=e.args[0], code='sbml_validation_exception', params={'error':e.args[1], 'line': '?'})