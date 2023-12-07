package main

import (
    "encoding/csv"
    "fmt"
    "regexp"
    "strconv"
    "strings"
)

const (
	MaxUint = ^uint(0)
    MaxInt = int(MaxUint >> 1)
)

type Almanac struct {
    Entries []*AlmanacEntry
}

type AlmanacEntry struct {
    Label string
    MapEntries []*AlmanacMapEntry
    Sources, Destinations []int
}

func newAlmanacEntry(label string) *AlmanacEntry {
    return &AlmanacEntry{
        Label: label,
        MapEntries: []*AlmanacMapEntry{},
        Sources: []int{},
        Destinations: []int{},
    }
}

func (a *AlmanacEntry) ExpandRanges() () {
    for _, e := range a.MapEntries {
        for i := e.DestinationStart; i < e.DestinationStart + e.RangeValue; i++ {
            a.Destinations = append(a.Destinations, i)
        }
        for i := e.SourceStart; i < e.SourceStart + e.RangeValue; i++ {
            a.Sources = append(a.Sources, i)
        }
    }
    if len(a.Sources) != len(a.Destinations) {
        panic("ExpandRanges generated different sizes for source and destination")
    }
}

type AlmanacMapEntry struct {
    DestinationStart int
    SourceStart int
    RangeValue int
}

func getSeeds(seedsInput string) []int {
    mapEntryRe := regexp.MustCompile("[0-9]+")
    var out []int
    for _, strSeed := range mapEntryRe.FindAllStringSubmatch(seedsInput, -1) {
        seed, err := strconv.Atoi(strSeed[0])
        panicIfError(err)
        out = append(out, seed)
    }
    return out
}

func getAlmanac() (*Almanac, []int) {
    // I ended up using this CSV parser because I was having a hard time
    // crafting a regex that matches everything between 2 new line characters.
    reader := csv.NewReader(strings.NewReader(input))
    readerOut, err := reader.ReadAll()
    panicIfError(err)

    var almanac Almanac
    mapLabelRe := regexp.MustCompile("^[A-Za-z-]+")
    mapEntryRe := regexp.MustCompile("[0-9]+")
    seeds := getSeeds(readerOut[0][0])
    for _, e := range readerOut[1:] {
        maybeLabel := mapLabelRe.FindString(e[0])
        if len(maybeLabel) > 0 {
            almanacEntry := newAlmanacEntry(maybeLabel)
            almanac.Entries = append(almanac.Entries, almanacEntry)
        } else {
            mapEntry := AlmanacMapEntry{}
            stringMapEntries := mapEntryRe.FindAllStringSubmatch(e[0], -1)
            if len(stringMapEntries) != 3 {
                panic("expected 3 values in each map entry")
            }
            destinationStart, err := strconv.Atoi(stringMapEntries[0][0])
            panicIfError(err)
            mapEntry.DestinationStart = destinationStart
            sourceStart, err := strconv.Atoi(stringMapEntries[1][0])
            panicIfError(err)
            mapEntry.SourceStart = sourceStart
            rangeValue, err := strconv.Atoi(stringMapEntries[2][0])
            panicIfError(err)
            mapEntry.RangeValue = rangeValue
            almanac.Entries[len(almanac.Entries)-1].MapEntries = append(almanac.Entries[len(almanac.Entries)-1].MapEntries, &mapEntry)
        }
    }
    return &almanac, seeds
}

func part1(almanac *Almanac, seeds []int) {
    closest := MaxInt
    closestSeed := -1
    for _, s := range seeds {
        source := s
        for _, a := range almanac.Entries {
            for _, e := range a.MapEntries {
                if source >= e.SourceStart && source < e.SourceStart + e.RangeValue {
                    source = e.DestinationStart + (source - e.SourceStart)
                    break
                }
            }
        }
        if source < closest {
            closest = source
            closestSeed = s
            fmt.Printf("\tclosest so far: %d (seed %d)\n", closest, s)
        }
    }
    fmt.Printf("Part 1 answer: closest location %d | seed: %d\n", closest, closestSeed)
}

func part2(almanac *Almanac, seedsRanges []int) {
    closest := MaxInt
    closestSeed := -1
    for i := 0; i < len(seedsRanges); i += 2 {
        for s := seedsRanges[i]; s < seedsRanges[i]+seedsRanges[i+1]; s++ {
            source := s
            for _, a := range almanac.Entries {
                for _, e := range a.MapEntries {
                    if source >= e.SourceStart && source < e.SourceStart+e.RangeValue {
                        source = e.DestinationStart + (source - e.SourceStart)
                        break
                    }
                }
            }
            if source < closest {
                closest = source
                closestSeed = s
                fmt.Printf("\tclosest so far: %d (seed %d)\n", closest, s)
            }
        }
        fmt.Printf("\tfinished with seed range starting in: %d\n", i)
    }
    fmt.Printf("Part 2 answer: closest location %d | seed: %d\n", closest, closestSeed)
}

func main() {
    almanac, seedsInfo := getAlmanac()
    part1(almanac, seedsInfo)
    fmt.Println("============================================================\n\n")
    part2(almanac, seedsInfo)
    fmt.Println("============================================================\n\n")
}

const input = `seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4`

func panicIfError(err error) {
    if err != nil {
        panic(err)
    }
}
