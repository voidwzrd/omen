import ArgumentParser
import Foundation

func runOllama(request: String) -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/local/bin/ollama")
    process.arguments = ["run", "llama3", request]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        print("Failed to run ollama:", error)
        return ""
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
}

func runGitDiff() -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    process.arguments = ["diff", "--staged"]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        print(error)
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
}

func runGit(args: [String]) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    process.arguments = args

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        print(error)
    }
}

@main
struct Omen: ParsableCommand {
    static let configuration: CommandConfiguration = CommandConfiguration(
        commandName: "omen",
        abstract: "Terminal app that stages changes with meaningful commit messages",
        version: "0.0.1"
    )
    func run() throws {
        runGit(args: ["add", "-A"])

        let gitDiff = runGitDiff()
        let commitRequestPrefix = "Write a concise git commit message based this git diff:"
        let ollamaRequestParameters =
        """
        Rules:
        - Output ONLY the commit message
        - No explanations
        - No quotes
        - No formatting
        - Use conventional commit style
        """

        let ollamaRequest =
        """
        \(commitRequestPrefix)
        \(gitDiff)
        \(ollamaRequestParameters)
        """

        let ollamaResponse = runOllama(request: ollamaRequest)
        runGit(args: ["commit", "-m", ollamaResponse])
    }
}