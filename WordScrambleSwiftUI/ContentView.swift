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
      }
    }

  //MARK: - Methods
  func addNewWord() {
    let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    guard answer.count > 0 else { return }
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
