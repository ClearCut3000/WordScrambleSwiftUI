//
//  ContentView.swift
//  WordScrambleSwiftUI
//
//  Created by Николай Никитин on 17.08.2022.
//

import SwiftUI

struct ContentView: View {

  //MARK: - Properties
  @State private var usedWords = [String]()
  @State private var rootWord = ""
  @State private var newWord = ""
  @State private var errorTitle = ""
  @State private var errorMessage = ""
  @State private var showingAlert = false
  @State private var score = 0
  @State private var isAnswerLimitOn = false
  @State private var placeholderText = "Enter your word..."

  //MARK: - View
  var body: some View {
    NavigationView {
      List {
        Section {
          TextField($placeholderText.wrappedValue, text: $newWord,
                    onCommit: { placeholderText = newWord })
            .textInputAutocapitalization(.none)
            .disableAutocorrection(true)
            .autocapitalization(.none)
        }
        Section {
          ForEach(usedWords, id: \.self) { word in
            HStack {
              Image(systemName: "\(word.count).circle")
              Text(word)
            }
          }
        }
      }
      .navigationTitle(rootWord)
      .onSubmit(addNewWord)
      .onAppear(perform: startGame)
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            restartGame()
          } label: {
            Image(systemName: "arrow.counterclockwise")
              .font(Font.title)
              .foregroundColor(Color(UIColor.red))
          }
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Text("Score: \(score)")
            .padding(6)
            .font(.system(size: 26, weight: .bold, design: .default))
            .background(score == 0 ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        ToolbarItem(placement: .bottomBar) {
          Button {
            isAnswerLimitOn.toggle()
          } label: {
            Text(isAnswerLimitOn ? "Hard mode is ON!" : "Hard mode is OFF")
              .font(.system(size: 22, weight: .bold, design: .default))
          }
          .padding(8)
          .background(isAnswerLimitOn ? Color.red : Color.green)
          .foregroundColor(isAnswerLimitOn ? .white : .black)
          .cornerRadius(10)
        }
      }
      .alert(errorTitle, isPresented: $showingAlert) {
        Button("OK", role: .cancel) { }
      } message: {
        Text(errorMessage)
          .font(.system(size: 24, weight: .semibold, design: .default))
      }
    }
  }

  //MARK: - Methods
  func addNewWord() {
    let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

    defer {
      newWord = ""
    }

    switch isAnswerLimitOn {
    case true:
      guard answer.count > 3, answer != newWord.prefix(3) else {
        wordError(title: "Oops!", message: "Answers must be more than 3 letters and not consist of the beginning of a keyword!")
        return
      }
    case false:
      guard answer.count > 0 else { return }
    }

    guard isOriginal(word: answer) else {
      wordError(title: "Word used already!", message: "Be more original!")
      return
    }
    guard isPossible(word: answer) else {
        wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
        return
    }

    guard isReal(word: answer) else {
        wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
        return
    }

    withAnimation {
      usedWords.insert(answer, at: 0)
      score += answer.count
    }
    newWord = ""
  }

  func startGame() {
    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
      if let startWords =  try? String(contentsOf: startWordsURL) {
        let allWords = startWords.components(separatedBy: "\n")
        rootWord = allWords.randomElement() ?? "silkworm"
        return
      }
    }
    fatalError("Couldn't load start.txt from bundle!")
  }

  func restartGame() {
    startGame()
    newWord = ""
  placeholderText = "Enter your word..."
    score = 0
    usedWords.removeAll()
  }

  func isOriginal(word: String) -> Bool {
    !usedWords.contains(word)
  }

  func isPossible(word: String) -> Bool {
    var tempWord = rootWord
    for letter in word {
      if let pos = tempWord.firstIndex(of: letter) {
        tempWord.remove(at: pos)
      } else {
        return false
      }
    }
    return true
  }

  func isReal(word: String) -> Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledWord = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    return misspelledWord.location == NSNotFound
  }

  func wordError(title: String, message: String) {
    errorMessage = message
    errorTitle = title
    showingAlert = true
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
