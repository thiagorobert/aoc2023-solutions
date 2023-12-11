# Tested in R version 4.1.2

library("hash")
library("stringr")
library("Matrix")


INPUT <- "..F7.
          .FJ|.
          SJ.L7
          |F--J
          LJ...";


pipes <- hash()
pipes[["|"]] <- list(list("|7FS"), list(""), list(""), list("|LJS"))
pipes[["-"]] <- list(list(""), list("-LFS"), list("-J7S"), list(""))
pipes[["L"]] <- list(list("|7FS"), list(""), list("-J7S"), list(""))
pipes[["J"]] <- list(list("|7FS"), list("-LFS"), list(""), list(""))
pipes[["7"]] <- list(list(""), list("-LFS"), list(""), list("|JLS"))
pipes[["F"]] <- list(list(""), list(""), list("-7JS"), list("|JLS"))
pipes[["."]] <- list(list(""), list(""), list(""), list(""))
pipes[["S"]] <- list(list("F7|"), list("-LF"), list("-J7"), list("|LJ"))


vnNeighborhood <- function (targetX, targetY, maxX, maxY) {
    out <- list()
    # North
     if (targetX - 1 < 1) {
         out <- append(out, list(c(-1, -1)))
     } else {
        out <- append(out, list(c(targetX - 1, targetY)))
     }
    # West
    if (targetY - 1 < 1) {
         out <- append(out, list(c(-1, -1)))
    } else {
        out <- append(out, list(c(targetX, targetY - 1)))
    }
    # East
    if (targetY + 1 > maxY) {
         out <- append(out, list(c(-1, -1)))
    } else {
        out <- append(out, list(c(targetX, targetY + 1)))
    }
    # South
    if (targetX + 1 > maxX) {
         out <- append(out, list(c(-1, -1)))
    } else {
        out <- append(out, list(c(targetX + 1, targetY)))
    }
    return(out)
}

ppDirection <- function (source, target, dIndex, compatible) {
    dText <- ""
    if (dIndex == 1) dText <- "N"
    if (dIndex == 2) dText <- "W"
    if (dIndex == 3) dText <- "E"
    if (dIndex == 4) dText <- "S"
    cText <- "NOT compatible"
    if (compatible) cText <- "IS  compatible"

    print(sprintf("(%s -> %s) %s: %s", source, target, dText, cText))
}

compatible <- function (source, vnn, inputMatrix) {
    if (source == ".")  panic("compatible: source tile is '.' - this should never happen")
    valid = pipes[source]

    comp <- list()
    out <- list()
    direction <- 0
    for (n in vnn) {
        direction <- direction + 1
        isCompatible <- FALSE
        un = unlist(n)
        target <- "X"
        if (un[1] != -1 && un[2] != -1) {
            target = unlist(inputMatrix[un[1], un[2]])
            strValid <- unlist(values(valid))[direction]
            isCompatible <- grepl(target, strValid, fixed=TRUE)
            out <- append(out, isCompatible)
        }
        if (isCompatible) {
            comp <- append(comp, list(c(un[1], un[2])))
        }
        out <- append(out, isCompatible)
        ppDirection(source, target, direction, isCompatible)
    }
    return(comp)
}

# Process input.
lines <- lapply(unlist(strsplit(INPUT, "\n")), str_trim, "left")

startPos <- NULL
allChars <- list()
for (i in seq_along(lines)) {
    parts <- unlist(strsplit(unlist(lines[i]), ""))
    for (j in seq_along(parts)) {
        if (parts[j] == 'S') {
            startPos <- list(i, j)
        }
        allChars <- append(allChars, parts[j])
    }
}

nRows <- length(lines)
nColumns <- length(allChars) / nRows
print(sprintf("***** Input dimensions: %d X %d", nRows, nColumns))

inputMatrix <- matrix(allChars, nRows, nColumns, byrow = T)

# Start position.
uStartPos <- unlist(startPos)
currentTile <- inputMatrix[uStartPos[1], uStartPos[2]][1]
vnn <- vnNeighborhood(uStartPos[1], uStartPos[2], nRows, nColumns)
available = compatible(currentTile, vnn, inputMatrix)

# Crawl.
newPlace <- function (targets, seen) {
    for (t in targets) {
        ut <- unlist(t)
        old <- FALSE
        for (s in seen) {
            us <- unlist(s)
            if(ut[1] == us[1] && ut[2] == us[2]) {
                 old <- TRUE
                 break
             }
        }
        if (old) next
        return(ut)
    }
    panic("newPlace: code block should be unreachable - this should never happen")
}

seen <- list()
seen <- append(seen, list(c(uStartPos[1], uStartPos[2])))
repeat {
    uCurrentPos = newPlace(available, seen)
    currentTile <- inputMatrix[uCurrentPos[1], uCurrentPos[2]][1]

    # Neighbors.
    vnn <- vnNeighborhood(uCurrentPos[1], uCurrentPos[2], nRows, nColumns)

    available = compatible(currentTile, vnn, inputMatrix)
    seen <- append(seen, list(c(uCurrentPos[1], uCurrentPos[2])))

    # HACK: remove the start position from the list of nodes seen after a while.
    if (length(seen) == 4) {
        newSeen <- list()
        for (s in seen) {
            us <- unlist(s)
            if(us[1] == uStartPos[1] && us[2] == uStartPos[2]) next
            newSeen = append(newSeen, list(c(us[1], us[2])))
        }
        seen = newSeen
    }

    if (currentTile == "S") {
        break
    }
}

halfTotal <- length(seen) / 2
print(sprintf("********** Part 1: the grand total: %d", halfTotal))
