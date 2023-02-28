# frozen_string_literal: true
ActiveRecord::Base.logger = Logger.new(STDOUT)

def populate_survey_questions
  clear_survey_questions
  group = Rapidfire::QuestionGroup.find_or_create_by(
    name: "Populated Survey",
    tags: ""
  )
  to_create = []
  
  n_questions = ENV['questions'] || 100

  1..n_questions.to_i.times do |i|
    to_create << {
      question_group_id: group.id, 
      question_text: "Question #{i}", 
      type: "Rapidfire::Questions::Checkbox", 
      position: i,
      answer_options: "A\r\nB\r\nC\r\nD",
      validation_rules: {
        presence: '1',
        grouped: '0',
        grouped_question: '',
        minimum: '',
        maximum: '',
        range_minimum: '',
        range_maximum: '',
        range_increment: '',
        range_divisions: '',
        range_format: '',
        greater_than_or_equal_to: '',
        less_than_or_equal_to: ''
      }
    }
  end
  Rapidfire::Question.insert_all(to_create)
end

def populate_survey_answers
  clear_survey_answers
  question_group = Rapidfire::QuestionGroup.find_by(name: "Populated Survey")
  to_create = []

  n_responses = ENV['responses'] || 100

  1..n_responses.to_i.times do |round|
    answer_group = Rapidfire::AnswerGroup.create(
      question_group_id: question_group.id,
      user_id: User.order('RAND()').first.id,
    )
    Rapidfire::Question.where(
      question_group_id: question_group.id,
    ).each do |question|
      to_create << {
        answer_group_id: answer_group.id,
        question_id: question.id,
        answer_text: ["A","B","C","D"].sample
      }
    end
  end
  Rapidfire::Answer.insert_all(to_create)
end

def clear_survey_answers
  question_group = Rapidfire::QuestionGroup.find_by(name: "Populated Survey")
  return unless question_group

  to_delete = []
  Rapidfire::AnswerGroup.where(
    question_group_id: question_group.id,
  ).each do |answer_group|
    Rapidfire::Answer.where(
      answer_group_id: answer_group.id
    ).each do |answer|
      to_delete << answer
    end
  end
  Rapidfire::Answer.delete(to_delete)
end

def clear_survey_questions
  question_group = Rapidfire::QuestionGroup.find_by(name: "Populated Survey")
  return unless question_group

  Rapidfire::Question.where(
    question_group_id: question_group.id,
  ).destroy_all
end
