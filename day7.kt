const val INPUT = """32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"""

fun tieBreak(hand1: String, hand2: String, jokerLowest: Boolean): Int {
    val h1Array = hand1.toCharArray()
    val h2Array = hand2.toCharArray()
    for(i in 0..h1Array.size) {
        if (h1Array.elementAt(i) == h2Array.elementAt(i)) {
            continue
        }

        // Return values are reversed to make Joker the lowest card.
        if (jokerLowest) {
            if (h1Array.elementAt(i) == 'J') return -1
            if (h2Array.elementAt(i) == 'J') return 1
        }
        if (h1Array.elementAt(i) == 'A') return 1
        if (h2Array.elementAt(i) == 'A') return -1
        if (h1Array.elementAt(i) == 'K') return 1
        if (h2Array.elementAt(i) == 'K') return -1
        if (h1Array.elementAt(i) == 'Q') return 1
        if (h2Array.elementAt(i) == 'Q') return -1
        if (h1Array.elementAt(i) == 'J') return 1
        if (h2Array.elementAt(i) == 'J') return -1
        if (h1Array.elementAt(i) == 'T') return 1
        if (h2Array.elementAt(i) == 'T') return -1

        if (h1Array.elementAt(i) > h2Array.elementAt(i)) {
            return 1
        } else if (h1Array.elementAt(i) < h2Array.elementAt(i)) {
            return -1
        }
    }
    return 0
}

// Uses the orignal cards; Jokers sit between Q and T on tie breaks.
val game1Comparator = object : Comparator<String> {
    override fun compare(hand1: String, hand2: String): Int {
        val r1 = repeatedCards(hand1)
        val r2 = repeatedCards(hand2)
        for((i, c) in r1.withIndex()) {
            if (c > r2[i]) return 1
            if (c < r2[i]) return -1
        }
        return tieBreak(hand1, hand2, jokerLowest=false)
    }
}

// Replaces Jokers with the most common non-Joker card; Jokers are lowest on tie breaks.
val game2Comparator = object : Comparator<String> {
    override fun compare(hand1: String, hand2: String): Int {
        val r1 = repeatedCards(replaceJoker(hand1))
        val r2 = repeatedCards(replaceJoker(hand2))
        for((i, c) in r1.withIndex()) {
            if (c > r2[i]) return 1
            if (c < r2[i]) return -1
        }
        return tieBreak(hand1, hand2, jokerLowest=true)
    }
}

fun replaceJoker(hand: String): String {
    val c = mostCommonNotJoker(cardCountMap(hand))
    return hand.replace('J', c)
}

fun mostCommonNotJoker(cardCountMap: Map<Char, Int>): Char {
    var out = '?'
    var max = -1
    cardCountMap.forEach { entry ->
        if (entry.value > max && entry.key != 'J') {
            max = entry.value
            out = entry.key
        }
    }
    return out
}

fun cardCountMap(hand: String): Map<Char, Int> {
    val charCount = mutableMapOf<Char, Int>()
    hand.toCharArray().forEach { charCount[it] = charCount.getOrDefault(it, 0) + 1 }
    return charCount
}

fun repeatedCards(hand: String): Array<Int> {
    val repeatedChars:Array<Int> = cardCountMap(hand).values.toTypedArray()
    repeatedChars.sortDescending()
    return repeatedChars
}

const val DEBUG = false

fun main() {
    val turnRe = "^(?<hand>[AKQJT98765432]+) (?<bid>[0-9]+)$".toRegex()

    val game = mutableMapOf<String, String>()
    for (line in INPUT.split("\n")) {
        val match = turnRe.find(line)!!
        val hand = match.groups["hand"]?.value!!
        val bid = match.groups["bid"]?.value!!
        game[hand] = bid
    }

    if (DEBUG) {
        for (h in game.keys) {
            val m = cardCountMap(h)
            val r = repeatedCards(h).joinToString(" ")
            val c = mostCommonNotJoker(m)
            println("$h: $r | $c")
        }
    }

    var sortedHands = game.keys.sortedWith(game1Comparator)
    var totalWinnings: Int = 0
    for((j, hand) in sortedHands.withIndex()) {
        totalWinnings += (j + 1) * game[hand]?.toInt()!!
    }
    println("\n\n********** Part 1: the grand total: $totalWinnings")


    sortedHands = game.keys.sortedWith(game2Comparator)
    totalWinnings = 0
    for((j, hand) in sortedHands.withIndex()) {
        totalWinnings += (j + 1) * game[hand]?.toInt()!!
    }
    println("\n\n********** Part 2: the grand total: $totalWinnings")
}