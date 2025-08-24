import Foundation

enum Fuzzy {
    static func normalize(_ s: String) -> String {
        let lower = s.lowercased()
        let folded = lower.folding(options: .diacriticInsensitive, locale: .current)
        let allowed = CharacterSet.alphanumerics.union(.whitespaces)
        return String(folded.unicodeScalars.filter { allowed.contains($0) })
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func acronym(of s: String) -> String {
        return s.split(whereSeparator: { !$0.isLetter }).compactMap { $0.first }.map(String.init).joined().lowercased()
    }

    static func score(query: String, candidate: String) -> Double {
        let q = normalize(query)
        let c = normalize(candidate)
        guard !q.isEmpty, !c.isEmpty else { return 0 }

        if c == q { return 1.0 }

        if let range = c.range(of: q) {
            let idx = c.distance(from: c.startIndex, to: range.lowerBound)
            let posBonus = max(0, 1.0 - Double(idx) / Double(max(1, c.count))) * 0.15
            return 0.82 + posBonus
        }

        let acr = acronym(of: candidate)
        if acr.hasPrefix(q) {
            let tightness = Double(q.count) / Double(max(1, acr.count))
            return 0.8 * tightness + 0.15
        }

        let qt = Set(q.split(separator: " ").map(String.init))
        let ct = Set(c.split(separator: " ").map(String.init))
        if !qt.isEmpty && qt.isSubset(of: ct) {
            return 0.78
        }

        let sim = 1.0 - Double(levenshtein(q, c)) / Double(max(q.count, c.count))
        let prefixPenalty = commonPrefixLength(q, c)
        let prefixBoost = min(0.1, Double(prefixPenalty) / Double(max(1, q.count)) * 0.1)
        return max(0, min(1, sim + prefixBoost))
    }

    static func sort(query: String, candidates: [String], minScore: Double = 0.55, limit: Int? = nil) -> [(name: String, score: Double)] {
        let scored = candidates.map { ($0, score(query: query, candidate: $0)) }
            .filter { $0.1 >= minScore }
            .sorted { (a, b) in
                if a.1 == b.1 {
                    if a.0.count != b.0.count { return a.0.count < b.0.count }
                    return a.0 < b.0
                }
                return a.1 > b.1
            }
        if let limit { return Array(scored.prefix(limit)) }
        return scored
    }

    private static func commonPrefixLength(_ a: String, _ b: String) -> Int {
        let ac = Array(a), bc = Array(b)
        var i = 0
        while i < ac.count && i < bc.count && ac[i] == bc[i] { i += 1 }
        return i
    }

    private static func levenshtein(_ aStr: String, _ bStr: String) -> Int {
        let a = Array(aStr), b = Array(bStr)
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }

        var prev = Array(0...b.count)
        var cur = Array(repeating: 0, count: b.count + 1)

        for i in 1...a.count {
            cur[0] = i
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                cur[j] = min(
                    prev[j] + 1,
                    cur[j - 1] + 1,
                    prev[j - 1] + cost
                )
            }
            swap(&prev, &cur)
        }
        return prev[b.count]
    }
}


