import ArgumentParser
import Foundation

@main
struct Omen: ParsableCommand {
    static let configuration: CommandConfiguration = CommandConfiguration(
        commandName: "omen",
        abstract: "Terminal app that stages changes with meaningful commit messages",
        version: "0.0.1"
    )
    func run() {
        print("Hello, omen!")
    }
}
