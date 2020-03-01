;extensions [rnd]

breed [bikes bike]
breed [thieves thief]
breed [policeofficer police]
breed [crimes crime]
breed [caught-thieves caught-thief]
breed [stolen steal]

breed [patch-owners patch-owner]

globals[
  count-police
  count-bikes
  count-stolen-during-tick
  count-thieves
]

patches-own[
  accessible?
  density
  police-walking-range?
]

thieves-own[
  hardship?
  crime-probability
  full?
  target
  explored-patches ;find bike
  path-back
  giveup?
]

bikes-own[
  desirability
  security
  stolen?
  stolen-time
]

policeofficer-own[
  free?
;  at-station?
 ; explored-patches ;find crime
 ; target
  ;path-back
]

to setup-policeofficer
  create-policeofficer ratio-policeofficer * population-size[
    set shape "person"
    set color blue
    move-to one-of patches with [accessible?]
    set free? true
  ]
end

to setup-thieves
  create-thieves ratio-thieves * population-size * 0.05[
    set shape "person"
    set color red
    move-to one-of patches with [accessible?]
    set full? false
    set target nobody
    set explored-patches[]
    set path-back[]
    set giveup? false
  ]
end

to setup-bikes
  create-bikes ratio-bikes * population-size * 0.2 [
    set shape "bike"
    set color white
    set size 3
    set desirability random-float 0.5
    set security random-float 0.5
    set stolen? false
    set stolen-time 0
    move-to one-of patches with [accessible?]
    move
  ]
end

to setup-neigbourhood
  ask patches[
    set accessible? true
    set police-walking-range? true
  ]
end

to setup
  __clear-all-and-reset-ticks
;  setup-density
  setup-neigbourhood
  set count-stolen-during-tick 0
  ask bikes [
    ifelse(any? (patches in-radius 20 with [accessible?]))[
      move-to min-one-of (patches in-radius 20 with [accessible?]) [distance myself]
    ]
    [die]
    ask thieves[
      ifelse(any? (patches in-radius 20 with [accessible? and not police-walking-range?]))[
        move-to min-one-of (patches in-radius 20 with [accessible? and not police-walking-range?]) [distance myself]
      ]
      [die]
    ]
  ]
  setup-policeofficer
  setup-thieves
  setup-bikes
end

to go
  set count-stolen-during-tick 0
  ask thieves[
    let possible-patches (patches in-radius 10 with [accessible?])
    if (any? possible-patches)[
      move-to one-of possible-patches
      ask other turtles-here [
        let random-number random-float 1
       if shape = "bike" and desirability > random-number[
          if security > random-number[
            hatch-bikes 1 [set stolen? true set color red ]
            die
            ]
          ]
        ]
      ]
    ]
  if stolen? [set stolen-time stolen-time + 1]


  tick
end

to move
  rt random 100
  lt random 100
  fd 1
end

to sell-bikes
  let sell-time random-float
  if stolen-time >
end
