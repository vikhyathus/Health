//
//  QuestionTask.swift
//  Health
//
//  Created by Vikhyath on 26/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import ResearchKit

public var QuestionTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    let instructionStep = ORKInstructionStep(identifier: "IntroStep")
    instructionStep.title = "The Questionary survey"
    instructionStep.text = "You just need to ask couple of question that we need to know to give you suggestions"
    steps += [instructionStep]
    
    let nameAnswerFormat = ORKTextAnswerFormat(maximumLength: 20)
    nameAnswerFormat.multipleLines = false
    let nameQuestionStepTitle = "What is your name"
    let nameQuestionStep = ORKQuestionStep(identifier: "QuestionStep", title: nameQuestionStepTitle, answer: nameAnswerFormat)
    steps += [nameQuestionStep]

    let questQuestionStepTitle = "How often do you donate blood"
    let textChoices = [
        ORKTextChoice(text: "Once in a month", value: "Once in a month" as NSString),
        ORKTextChoice(text: "Once in six month", value: "Once in six month" as NSString),
        ORKTextChoice(text: "Never", value: "Never" as NSString)
    ]
    let questAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
    let questQuestionStep = ORKQuestionStep(identifier: "TextChoiceQuestionStep", title: questQuestionStepTitle, answer: questAnswerFormat)
    steps += [questQuestionStep]

    //Question 2
    let foodQuestionType = "Did you eat junk food today?"
    let foodtextChoices = [
        ORKTextChoice(text: "Yes", value: "1" as NSString),
        ORKTextChoice(text: "No", value: "0" as NSString)
    ]
    let foodAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: foodtextChoices)
    let foodQuestionStep = ORKQuestionStep(identifier: "foodQuestion", title: foodQuestionType, answer: foodAnswerFormat)
    steps += [foodQuestionStep]
    
    
    //Question 3
    let stressQuestionType = "Do you feel stressed right now?"
    let stressTextChoices = [
        ORKTextChoice(text: "Yes", value: "1" as NSString),
        ORKTextChoice(text: "No", value: "0" as NSString)
    ]
    let stressAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: stressTextChoices)
    let stressQuestionStep = ORKQuestionStep(identifier: "stressQuestion", title: stressQuestionType, answer: stressAnswerFormat)
    steps += [stressQuestionStep]
    
    
    //Question 4
    let sleepQuestionType = "Did you have enough sleep today?"
    let sleepTextChoices = [
        ORKTextChoice(text: "Yes", value: "1" as NSString),
        ORKTextChoice(text: "No", value: "0" as NSString)
    ]
    let sleepAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: sleepTextChoices)
    let sleepQuestionStep = ORKQuestionStep(identifier: "sleepQuestion", title: sleepQuestionType, answer: sleepAnswerFormat)
    steps += [sleepQuestionStep]
    
    //Question 5
//    let QuestionType = ""
//    let sleepTextChoices = [
//        ORKTextChoice(text: "Yes", value: "1" as NSString),
//        ORKTextChoice(text: "No", value: "0" as NSString)
//    ]
//    let sleepAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: sleepTextChoices)
//    let sleepQuestionStep = ORKQuestionStep(identifier: "sleepQuestion", title: sleepQuestionType, answer: sleepAnswerFormat)
//    steps += [sleepQuestionStep]
    
    
    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Right. Off you go!"
    summaryStep.text = "That was easy!"
    steps += [summaryStep]

    return ORKOrderedTask(identifier: "QuestionTask", steps: steps)
}
