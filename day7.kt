const val INPUT = """32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"""

enum class HandTypes {
    FIVE,
    FOUR,
    FULL_HOUSE,
    THREE,
    TWO_PAIR,
    ONE_PAIR,
    HIGH_CARD,
    DUD
}

fun handType(hand: String): HandTypes? {
    val sorted = hand.toCharArray().sorted().joinToString("").toCharArray()
    // println(sorted)
    var repeatedChars = arrayOf<Int>()
    var nRepeated = 1
    var lastChar = sorted[0]
    for (c in sorted.drop(1)) {
        if (c == lastChar) {
            nRepeated += 1
        } else {
            repeatedChars += nRepeated
            lastChar = c
            nRepeated = 1
        }
    }
    repeatedChars += nRepeated

    repeatedChars.sortDescending()
    // println(repeatedChars.joinToString(""))
    if (repeatedChars.first() == 5) return HandTypes.FIVE
    if (repeatedChars.first() == 4) return HandTypes.FOUR
    if (repeatedChars.first() == 3 && repeatedChars.elementAt(1) == 2) return HandTypes.FULL_HOUSE
    if (repeatedChars.first() == 3) return HandTypes.THREE
    if (repeatedChars.first() == 2 && repeatedChars.elementAt(1) == 2) return HandTypes.TWO_PAIR
    if (repeatedChars.first() == 2) return HandTypes.ONE_PAIR
    if (repeatedChars.size == 5) return HandTypes.HIGH_CARD
    return HandTypes.DUD
}

fun tieBreak(hand1: String, hand2: String): Int {
    val h1Array = hand1.toCharArray()
    val h2Array = hand2.toCharArray()
    for(i in 0..h1Array.size) {
        if (h1Array.elementAt(i) == h2Array.elementAt(i)) {
            continue
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

val handComparator = object : Comparator<String> {
    override fun compare(hand1: String, hand2: String): Int {
        val ht1 = handType(hand1)
        //println(ht1)
        val ht2 = handType(hand2)
        //println(ht2)

        if (ht1 == ht2) {
            return tieBreak(hand1, hand2)
        }
        if (ht1 == HandTypes.FIVE) return 1
        if (ht2 == HandTypes.FIVE) return -1
        if (ht1 == HandTypes.FOUR) return 1
        if (ht2 == HandTypes.FOUR) return -1
        if (ht1 == HandTypes.FULL_HOUSE) return 1
        if (ht2 == HandTypes.FULL_HOUSE) return -1
        if (ht1 == HandTypes.THREE) return 1
        if (ht2 == HandTypes.THREE) return -1
        if (ht1 == HandTypes.TWO_PAIR) return 1
        if (ht2 == HandTypes.TWO_PAIR) return -1
        if (ht1 == HandTypes.ONE_PAIR) return 1
        if (ht2 == HandTypes.ONE_PAIR) return -1
        return tieBreak(hand1, hand2)
    }
}

fun main() {
    val turnRe = "^(?<hand>[AKQJT98765432]+) (?<bid>[0-9]+)$".toRegex()

    val game = mutableMapOf<String, String>()
    for (line in INPUT.split("\n")) {
        val match = turnRe.find(line)!!
        val hand = match.groups["hand"]?.value!!
        val bid = match.groups["bid"]?.value!!
        game[hand] = bid
    }

    val sortedHands = game.keys.sortedWith(handComparator)
    println(game)
    println(sortedHands)
    var totalWinnings: Int = 0
    for((i, h) in sortedHands.withIndex()) {
        totalWinnings += (i + 1) * game[h]?.toInt()!!
    }
    println("\n\n********** Part 1: the grand total: $totalWinnings")
}