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
    let nameQuestionStepTitle = "What is your name?"
    let nameQuestionStep = ORKQuestionStep(identifier: "QuestionStep", title: nameQuestionStepTitle, answer: nameAnswerFormat)
    steps += [nameQuestionStep]

    let questQuestionStepTitle = "What is your quest?"
    let textChoices = [
        ORKTextChoice(text: "Create a ResearchKit App", value: 0 as NSNumber),
        ORKTextChoice(text: "Seek the Holy Grail", value: 1 as NSNumber),
        ORKTextChoice(text: "Find a shrubbery", value: 2 as NSNumber)
    ]
    let questAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
    let questQuestionStep = ORKQuestionStep(identifier: "TextChoiceQuestionStep", title: questQuestionStepTitle, answer: questAnswerFormat)
    steps += [questQuestionStep]

    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Right. Off you go!"
    summaryStep.text = "That was easy!"
    steps += [summaryStep]

    return ORKOrderedTask(identifier: "QuestionTask", steps: steps)
}

