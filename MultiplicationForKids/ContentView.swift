import SwiftUI

enum GameState {
    case inGame, settings, results
}

struct Question {
    var text: String
    var answer: Int
}

struct CircleImage: View {
    @State var systemName: String
    var body: some View {
        ZStack {
            Circle()
                .fill(.gray)
                .frame(width: 100, height: 100)
            Image(systemName: systemName)
                .font(.largeTitle)
                .foregroundColor(.black)
        }
    }
}

struct CircleText: View {
    @State var number: Int
    var body: some View {
        ZStack {
            Circle()
                .fill(.gray)
                .frame(width: 100, height: 100)
            Text("\(number)")
                .font(.largeTitle)
                .foregroundColor(.black)
                .bold()
        }
    }
}

struct ContentView: View {

    @State private var gameState: GameState = .settings
    @State private var upTo = 10
    @State private var from = 3
    @State private var questionsCount = 5
    @State private var questionsTypes = 1...30
    @State private var questions = [Question]()
    @State private var answers = [Int]()
    @State private var currentQuestion = 0
    @State private var currentAnswer = ""

    var body: some View {
        NavigationView {
            switch gameState {
                case .settings:
                    List {
                        Section {
                            Stepper("From \(from)", value: $from, in: 0...20, step: 1)
                            Stepper("Up to \(upTo)", value: $upTo, in: 0...20, step: 1)
                        } header: {
                            Text("Difficulty")
                        }
                        Section {
                            Picker("How many questions", selection: $questionsCount) {
                                ForEach(questionsTypes, id: \.self) {
                                    Text("\($0)")
                                }
                            }
                            .pickerStyle(.wheel)
                        } header: {
                            Text("Number of questions")
                        }
                    }
                    .navigationTitle("Settings")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                generateQuestions()
                                gameState = .inGame
                            } label: {
                                Text("Play")
                                    .bold()
                            }
                        }
                    }
                case .inGame:
                    VStack {
                        Text("\(questions[currentQuestion].text) \(currentAnswer)")
                            .font(.largeTitle)
                        VStack {
                            ForEach(1..<4, id: \.self) { row in
                                HStack {
                                    ForEach((row == 1 ? 1 : row == 2 ? 4 : 7)..<(row == 1 ? 4 : row == 2 ? 7 : 10), id: \.self) { number in
                                        Button {
                                            enterNumber(number: number)
                                        } label: {
                                            CircleText(number: number)
                                        }
                                    }
                                }
                            }
                            HStack {
                                Button(action: nextQuestion) {
                                    CircleImage(systemName: "paperplane.fill")
                                }
                                Button {
                                    enterNumber(number: 0)
                                } label: {
                                    CircleText(number: 0)
                                }
                                Button(action: deleteNumber) {
                                    CircleImage(systemName: "delete.left.fill")
                                }
                            }
                        }
                    }
                    .navigationTitle("Multiplication")
                case .results:
                    List {
                        ForEach(0..<questions.count, id: \.self) { i in
                            let correct = questions[i].answer == answers[i]
                            HStack {
                                Image(systemName: correct ? "checkmark" : "xmark")
                                    .foregroundColor(correct ? .green : .red)
                                Text("\(questions[i].text) \(answers[i])")
                                if !correct {
                                    Spacer()
                                    Text("Correct answer: \(questions[i].answer)")
                                }
                            }
                        }
                    }
                    .navigationTitle("Results")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                gameState = .settings
                            } label: {
                                Text("Play again")
                                    .bold()
                            }
                        }
                    }
            }
        }
    }

    func nextQuestion() {
        answers.append(Int(currentAnswer) ?? -1)
        currentAnswer = ""
        if questions.count != currentQuestion + 1 {
            currentQuestion += 1
        } else {
            gameState = .results
        }
    }

    func enterNumber(number: Int) {
        if currentAnswer != "" {
            currentAnswer += "\(number)"
        } else {
            currentAnswer = "\(number)"
        }
    }

    func deleteNumber() {
        if currentAnswer == "" { return }
        if currentAnswer.count == 1 {
            currentAnswer = ""
        } else {
            let _ = currentAnswer.popLast()
        }
    }

    func generateQuestions() {
        currentQuestion = 0
        answers.removeAll()
        questions.removeAll()
        let array = Array(from...upTo)
        for _ in 0..<questionsCount {
            let a = array.randomElement() ?? 1
            let b = array.randomElement() ?? 1
            let question = Question(text: "\(a) * \(b) =", answer: a * b)
            questions.append(question)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark)
    }
}
