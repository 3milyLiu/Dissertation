;;;;VERSION FROM 3/3/2020

; - design (DIAGRAMS)
; - specification
; - sell time needs to be increased



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
  day?
  enforce?
  count-total
  ticketyticktick
  network?
  secure-advice?
  goal
  operators
  inputs
]

patches-own[
  accessible?
  density
  q-val-north
  q-val-south
  q-val-east
  q-val-west
]

thieves-own[
  crime-probability
  full?
  giveup?
  giveup-time
  strategy
]

bikes-own[
  desirability
  security
  stolen?
  stolen-time
  total
]

policeofficer-own[
  free?
  police-time
  busy-time
]

to setup-policeofficer
  create-policeofficer ratio-policeofficer * population-size * 0.01[
    set shape "person"
    set color yellow
    move-to one-of patches with [accessible?]
    set free? true
    set police-time 0
    set busy-time 0
    set enforce? false
  ]
end

to setup-thieves
  create-thieves ratio-thieves * population-size * 0.05[
    setxy random-xcor random-ycor
    set shape "person"
    set color red
    move-to one-of patches with [accessible?]
    set full? false
    set giveup? false
    set giveup-time 0
    set crime-probability random-float 1
    set network? false

  ]
end

to setup-bikes
  create-bikes ratio-bikes * population-size * 0.2 [
    set shape "bike"
    set color white

    set size 2
    set desirability random-float 1
    set security random-float 1
    set stolen? false
    set stolen-time 0
    move-to one-of patches with [accessible?]
    move
    set total 0
    set secure-advice? false
  ]
end

to setup-neigbourhood
  ask patches[
    set accessible? true
  ]
end

to setup
  __clear-all-and-reset-ticks
  setup-neigbourhood
  set count-stolen-during-tick 0
  set count-total 0
  setup-policeofficer
  setup-thieves
  setup-bikes
  set-patch
  set ticketyticktick false
  tick
end

to set-patch
  ask patches[
    ; if any? thieves-here[
    if (thieves-here = true)[
      set q-val-north 0
      set q-val-east 0
      set q-val-south 0
      set q-val-west 0
    ]
    ;if any? bikes-here[
    if (bikes-here = true)[
      set q-val-north 10
      set q-val-east 10
      set q-val-south 10
      set q-val-west 10
    ]
    ;if any? policeofficer-here[
    if (policeofficer-here = true)[
      set q-val-north -10
      set q-val-east -10
      set q-val-south -10
      set q-val-west -10
    ]
  ]
end

to go
  thief-move
  ask policeofficer[
    ifelse (enforce?) [police-enforce][just-steal]
    ifelse (enforce?) [
      set police-time police-time + 1
      police-enforce
      just-steal
      set ticketyticktick true
    ]
    [if secure-advice? [secure-bikes]
      just-steal]


    ]

  ifelse (ticketyticktick = true)[tick][tick]
  just-steal
  spawn-thief
  if ticks >= 260 [stop]
end

to just-steal
  set ticketyticktick true
  ask bikes[
    if stolen?[
      set stolen-time stolen-time + 1
      sell-bikes
    ]
  ]
  let random-number random-float 1
  ask thieves[
    if not full?[
      if any? bikes-here [
        ask other bikes-here[
          if (shape = "bike") and (color = white) [
            if desirability > random-number[
              if security < random-number[
                set count-total count-total + 1
                hatch-bikes 1 [set stolen? true set color red]
                die
                ask thieves[
                  set full? true
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
  display


end

to thief-move
  ask thieves[
    let current-xcor xcor
    let current-ycor ycor
    set heading ((random 4) * 90)
    let probability random-float 1
    ifelse(probability < 0.8)[
    ][
      ifelse(probability < 0.9)[
        set heading(heading + 90)]
      [set heading(heading - 90)]]
    fd 1

  set-qvalue current-xcor current-ycor heading xcor ycor
    ;just-steal
  ]
  set-patch
end

to set-qvalue[current-xcor current-ycor current-heading new-xcor new-ycor]
  ; Q(s',a') optimal future value
  let optimal-f-val 0

  ;compute optimal future value
  ask patch new-xcor new-ycor[
     set optimal-f-val (max (list q-val-north q-val-east q-val-south q-val-west))
  ]

  ;computed q-values
  ask patch current-xcor current-ycor[
    ;reward + 10, gamma 0.1 alpha 0.2
    ; thieves are a bit dumb so gamma is 0.1
    ; alpha 0.2 slow learning
    let alpha 0.2
    let gamma 0.1
    let reward 10
  if(current-heading = 0)[
    ;; north
    set q-val-north (precision (q-val-north + alpha * (reward + (gamma * optimal-f-val) - q-val-north)) 1)
    ]
  if(current-heading = 90)[
    ;; east
    set q-val-east (precision (q-val-east + alpha * (reward + (gamma * optimal-f-val) - q-val-east)) 1)
    ]
  if(current-heading = 180)[
    ;; south
    set q-val-south (precision (q-val-south + alpha * (reward + (gamma * optimal-f-val) - q-val-south)) 1)

    ]
  if(current-heading = 270)[
    ;; west
    set q-val-west (precision (q-val-west + alpha * (reward + (gamma * optimal-f-val) - q-val-west)) 1)

    ]
]

end




to move
  rt random 100
  lt random 100
  fd 1
end

;thief sells bikes
;random duration, thief does not always offload quickly
to sell-bikes
  ifelse (stolen-time > random 1000)[
    hatch-bikes 1 [set stolen? false set color white]
      ask thieves[
      set full? false
    ]
    die
  ]
  [ask thieves[set full? true]]

end

;penalty for theft, share within network
; 50/50 chance they listen or ignore
to thief-network
  ;ask thieves[
  ask one-of thieves[
    let chance random-float 1
    if (chance > 0.5)[
    ;ask other turtles-here[
      ask turtles in-radius 10[
        if (shape = "person") and (color = red) [
          set crime-probability crime-probability - 0.02
        ]
      ]
    ]
  ]
end

;educate better locking
; 50/50 chance they listen or ignore
to secure-bikes
  ask one-of bikes[
    let chance random-float 1
    if (chance > 0.5)[
      ask turtles in-radius 5[
        if (shape = "bike") and (color = white) [
          set security security - 0.005
        ]
      ]
    ]
  ]
end

;police actively attempt to seek out thefts in action
to police-enforce
  ask policeofficer[
    ;set ticketyticktick true
    set police-time police-time + 1
    set-busyOrFree
    if free?[
      let possible-patches (patches in-radius 2 with [accessible?])
      if (any? possible-patches)[
        move-to one-of possible-patches
        ask other turtles-here [
          if shape = "person"[
            ask thieves[
              set crime-probability crime-probability - (crime-probability * 0.25)
              if crime-probability < 0.01 [
              set giveup? true
                if (network?) and  (enforce?) [thief-network]
                ;if secure-advice?[secure-bikes]
                if giveup?[
                  set giveup-time giveup-time + 1
                  quit-thief
          ]
              ]

        ]
        ]
  ]
  ]

;      set-busyOrFree
    ]
    set ticketyticktick false
  ]

end

;police officer is not always free
to set-busyOrFree
  ask policeofficer[
    ifelse police-time > 5[
      set free? false
      set busy-time busy-time + 1
      if busy-time > 200[
        set free? true
        set busy-time 0
    ]][set free? true]

;    if busy-time  10[
;      set busy-time 0
;      set police-time 0
;      set free? true
;      ]
    ]
end

;thieves give up thieving
to quit-thief
  ask thieves[
    if giveup-time > random 150[
      die
    ]
  ]
end

;new thieves start thieving
to spawn-thief
  if (count thieves < 10)[
  create-thieves random 15[
    set shape "person"
    set color red
    move-to one-of patches with [accessible?]
    set full? false
    set giveup? false
    set giveup-time 0
    set crime-probability random-float 1
  ]
  ]

end
