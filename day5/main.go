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

func (a Almanac) ExpandAllRanges() {
    for _, e := range a.Entries {
        e.ExpandRanges()
    }
}

func (a Almanac) EntryFor(label string) *AlmanacEntry {
    for _, e := range a.Entries {
        if e.Label == label {
            return e
        }
    }
    panic("MapEntriesFor called with invalid input label: " + label)
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

// Its absurd we have to do this instead of having a primitive.
func intInSlice(a int, list []int) (bool, int) {
    for index, b := range list {
        if b == a {
            return true, index
        }
    }
    return false, -1
}

func getClosestLocation(locationToSeed map[int]int) int {
    closest := MaxInt
    for k := range locationToSeed {
        if k < closest {
            closest = k
        }
    }
    return closest
}

func getFarthestLocation(locations []int) int {
    farthest := 0
    for k := range locations {
        if k > farthest {
            farthest = k
        }
    }
    return farthest
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
    //fmt.Println(seeds)
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

    //almanacJson, err := json.MarshalIndent(almanac, "", "  ")
    //panicIfError(err)
    //fmt.Printf("%s\n", string(almanacJson))
}

func part1(almanac *Almanac, seeds []int) {
    locationToSeed := map[int]int{}
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
        locationToSeed[source] = s
    }
    closest := getClosestLocation(locationToSeed)
    fmt.Printf("Part 1 answer: closest location %d | seed: %d\n", closest, locationToSeed[closest])
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

const input = `seeds: 3943078016 158366385 481035699 103909769 3553279107 15651230 3322093486 189601966 2957349913 359478652 924423181 691197498 2578953067 27362630 124747783 108079254 1992340665 437203822 2681092979 110901631

seed-to-soil map:
2702707184 1771488746 32408643
1838704579 89787943 256129587
3308305769 3945110092 140077818
3628160213 4264964536 30002760
3481822196 4118626519 146338017
2314039806 0 23017018
2094834166 23017018 66770925
13529560 2374830476 266694587
1360948085 2280951884 93878592
2337056824 1405838386 365650360
2735115827 1389537903 16300483
2161605091 1122407194 152434715
2944685788 3581490111 363619981
3448383587 4085187910 33438609
293095451 1923371965 152989927
555976625 1361056107 28481796
0 2076361892 13529560
4055868219 3342391034 239099077
3658162973 2944685788 397705246
446085378 2641525063 109891247
584458421 685760755 436646439
1647644147 2089891452 191060432
1528169571 1832460171 90911794
1619081365 1803897389 28562782
280224147 1348184803 12871304
1021104860 345917530 339843225
1454826677 1274841909 73342894

soil-to-fertilizer map:
370579153 1660655546 474809840
1390384163 3890794774 29044725
3933903064 3062217622 43562309
2579648014 2135465386 381757066
3905615715 3862507425 28287349
4053211235 382332912 208377334
3718132574 4107484155 187483141
3977465373 306587050 75745862
1866333065 230994048 75593002
1268904151 2940737610 121480012
3646057320 3790432171 72075254
845388993 2517222452 423515158
2291172026 769577840 288475988
4261588569 3919839499 33378727
2112304432 590710246 178867594
1419428888 1213751369 446904177
2961405080 3105779931 684652240
230994048 3967899050 139585105
2097623608 3953218226 14680824
1941926067 1058053828 155697541

fertilizer-to-water map:
0 1551952886 33233684
961721436 932763195 63696624
2767354703 3875238046 18117484
3717194106 2676555200 188038931
799543557 483022915 162177879
2428347038 3081230279 28566103
2872288153 3519235797 218585862
215425000 1162608123 279396952
1473270503 411403786 71619129
2762028477 2930057227 5326226
3263853515 2169144956 62130350
3330983617 2935383453 10086546
2522376237 2231275306 106924906
2757818051 2103190872 4210426
3090874015 3187643516 172979500
2785472187 2530367956 37190043
1365587214 49710602 107683289
554985341 330919476 80484310
3639346972 3109796382 77847134
1964878739 1442005075 21531118
2098191120 3737821659 137416387
1832452033 298110266 32809210
2456913141 2864594131 65463096
1025418060 1606654056 340169154
2277580887 2475812485 29651215
2416229303 2107401298 12117735
33233684 176973083 62797441
157085258 239770524 58339742
2307232102 2567557999 108997201
1915168137 0 49710602
2235607507 3893355530 41973380
1865261243 1502045992 49906894
3905233037 3935328910 231121478
494821952 157393891 19579192
514401144 996459819 40584197
4136354515 3360623016 158612781
3503586692 2945469999 135760280
635469651 1463536193 38509799
2629301143 4166450388 128516908
2822662230 2119519033 49625923
3325983865 2098191120 4999752
3341070163 2338200212 137612273
3478682436 2505463700 24904256
96031125 1971548655 36328688
1986409857 1585186570 21467486
673979450 1037044016 125564107
1544889632 645200794 287562401
132359813 1946823210 24725445

water-to-light map:
3326310943 1150412752 87200223
4257088620 4233111242 37878676
3994159838 4060724644 54228568
3876001808 4114953212 90976210
2886658207 1485800780 134153427
3966978018 4205929422 27181820
4048388406 3874470488 149045901
528406865 502600485 237825862
111547576 1241598488 111964267
3068561383 1485461466 339314
3168255879 3056441319 158055064
3504257503 1453325844 32135622
2109734789 3372472386 240074722
3068900697 403245303 99355182
2027101388 740426347 82633401
1219093087 1970502974 808008301
3643122008 1951548756 18954218
2603944924 279757237 123488066
766232727 0 10960493
3712182589 4270989918 1531320
3536393125 2778511275 106728883
3482397575 1237612975 3985513
777193220 1763962961 71462615
1117452579 1680930659 83032302
3413511166 3214496383 46428427
2432743763 2885240158 171201161
0 3260924810 111547576
3486383088 1835425576 17874415
3672475952 3703073187 39706637
848655835 10960493 268796744
4197434307 4023516389 37208255
3459939593 823059748 22457982
2727432990 1853299991 98248765
4234642562 4272521238 22446058
3713713909 3672475952 30597235
2351588880 1353562755 81154883
223511843 845517730 304895022
3744311144 3742779824 131690664
1200484881 1434717638 18608206
3020811634 3612547108 47749749
2349809511 3660296857 1779369
2825681755 1619954207 60976452

light-to-temperature map:
252460180 3718023854 80580651
3778113118 1519654737 306188725
333040831 2573805517 96168275
4084301843 3798604505 210665453
1694244932 1825843462 379128459
1487313708 2669973792 206931224
429209106 2876905016 268167573
3133421217 3610326681 107697173
1486370741 3145072589 942967
697376679 3146015556 464311125
2152115592 836439718 249469053
3241118390 214400336 17576418
214400336 1164650972 38059844
2073373391 1085908771 78742201
1161687804 2248952614 324682937
3258694808 231976754 268511965
3527206773 1312729085 206925652
3133251251 2573635551 169966
2930227394 4091943439 203023857
2484258126 790765872 45673846
2639950241 500488719 290277153
2529931972 1202710816 110018269
2401584645 4009269958 82673481
3734132425 2204971921 43980693

temperature-to-humidity map:
168091833 268406932 76258451
3449803430 2843367435 19310453
2007621581 1615073306 528954706
1947960540 798304921 59661041
3469113883 3441273912 247683303
3980335429 3688957215 155495519
1382488646 1289756018 231480201
1613968847 2144028012 203484286
3030343754 2862677888 310561319
311459258 1257812898 31943120
3716797186 4024477040 263538243
743249314 734822904 63482017
2843367435 4288015283 6952013
244350284 201297958 67108974
806731331 549427536 185395368
33679712 344665383 134412121
1817453133 1521236219 93837087
2850319448 3844452734 180024306
1193424657 2347512298 189063989
992126699 0 201297958
3340905073 3173239207 108898357
343402378 857965962 399846936
0 479077504 33679712
4135830948 3282137564 159136348
1911290220 512757216 36670320

humidity-to-location map:
1586270647 2666237958 31388199
1639118951 2401662894 243114959
673413244 1218441073 9004417
4189219561 4197782169 97185127
339701505 993997384 224443689
2088925654 1227445490 16145987
3048450614 2034241441 196558736
3245009350 3057456069 37064056
1990947272 217743214 23964128
755791330 433456361 436687719
3750378482 1243591477 29460651
1347952933 3094520125 238317714
682417661 3593572644 73373669
1891967948 3494593320 98979324
2746577216 1325573050 27089148
90823161 3346797254 147796066
238619227 1933159163 101082278
2884769306 269775053 163681308
564145194 0 109268050
2014911400 1273052128 12916400
2773666364 1295702566 29870484
0 903174223 90823161
4286404688 3841991082 8562608
1617658846 2644777853 21460105
2714916854 3748178771 31660362
2275934358 3332837839 13959415
2027827800 870144080 33030143
3841991082 4158641967 39140202
3881131284 3850553690 308088277
3390548570 2697626157 359829912
1882233910 1285968528 9734038
2105071641 2230800177 170862717
1192479049 1777685279 155473884
2803536848 3666946313 81232458
2289893773 1352662198 425023081
2060857943 241707342 28067711
3282073406 109268050 108475164`


const tinput = `seeds: 79 14 55 13

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


func solutionsThatRequireExpandingRange() {
    almanac, seeds := getAlmanac()
    almanac.ExpandAllRanges()

    // A solution that requires expanded ranges and starts by iterating over seeds.
    locationToSeed := map[int]int{}
    for _, s := range seeds {
        source := s
        for i, e := range almanac.Entries {
            inSlice, index := intInSlice(source, e.Sources)
            if inSlice {
                source = almanac.Entries[i].Destinations[index]
            }
        }
        locationToSeed[source] = s
    }
    closest := getClosestLocation(locationToSeed)
    fmt.Printf("Part 1 answer: closest location %d | seed: %d\n", closest, locationToSeed[closest])




    // A solution that requires expanded ranges and starts by iterating closest locations.
    var sortedLocations []int
    for i := 0; i <= getFarthestLocation(almanac.EntryFor("humidity-to-location").Destinations); i++ {
        sortedLocations = append(sortedLocations, i)
    }

    for _, l := range sortedLocations {
        destination := l
        for i := len(almanac.Entries) - 1; i >= 0; i-- {
            inSlice, index := intInSlice(destination, almanac.Entries[i].Destinations)
            if inSlice {
                destination = almanac.Entries[i].Sources[index]
            }
        }
        inSlice, _ := intInSlice(destination, seeds)
        if inSlice {
            fmt.Printf("Part 1 answer: closest location %d | seed: %d\n", l, destination)
            break
        }
    }
}
