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

  //MARK: - View
  var body: some View {
    NavigationView {
      List {
        Section {
          TextField("Enter your word", text: $newWord)
            .textInputAutocapitalization(.none)
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
      .alert(errorTitle, isPresented: $showingAlert) {
        Button("OK", role: .cancel) { }
      } message: {
        Text(errorMessage)
      }
    }
  }

  //MARK: - Methods
  func addNewWord() {
    let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    guard answer.count > 0 else { return }

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
