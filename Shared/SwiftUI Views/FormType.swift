//
//  FormType.swift
//  Shared (Type)
//
//  Created by Tanner on 9/18/21.
//

/**
 An enumeration for describing a form.
 
 Enumerations include: .New, .Add, & .Edit
 */
enum FormType {
    case New
    case Add
    case Edit
}

/**
 Evaluates a logical expression to determine if the form is for adding a new object.
 
 - Parameters:
    - formType: The form type enum
 
 - Returns: `true` if the form is for a new or add object, `false` otherwise.
 */
func isNewForm(_ formType: FormType) -> Bool {
    return (formType == .New || formType == .Add)
}

/**
 Evaluates a logical expression to determine if the form is only for a new object.
 
 - Parameters:
    - formType: The form type enum
 
 - Returns: `true` if the form is only for a new object, `false` otherwise.
 */
func isBrandNewForm(_ formType: FormType) -> Bool {
    return formType == .New
}
