;each tick is representative of 1 hour
;bikes not returning
;gamma and alpha changed to 0.8

;possible interventions

;6264 ticks = 261 days
;model only models working days Mon-Fri (footfall in the City dramatically reduces on weekends)

breed [bikes bike]
breed [thieves thief]
breed [policeofficer police]

globals[
  ;count-police
  ;count-bikes
  ;count-thieves
  count-total
  enforce?
  hide?
  police-thief?
  police-bike?
  bikemarking?
  recovered
]

patches-own[
  accessible?
  q-val-north
  q-val-south
  q-val-east
  q-val-west
]

thieves-own[
  crime-probability
  birth-tick
  hidden?
]

bikes-own[
  desirability
  security
  stolen?
  birth-tick
  show?
  marked?
  advised?
]

to init-map
  import-pcolors "./images/london.png"
  ask patches[
    set accessible? true
    if pcolor = 28.6 [set accessible? false]
  ]
end


to setup-bikes
  create-bikes ratio-bikes * population-size [
  spawn-bike

]
end

to setup-thieves
  create-thieves ratio-thieves * population-size [
    spawn-thief
  ]
end

to setup-policeofficer
  create-policeofficer ratio-policeofficer * population-size / 40[
    spawn-police
  ]
end

to setup
  __clear-all-and-reset-ticks
  init-map
  setup-bikes
  setup-thieves
  setup-policeofficer
  set hide? false
end

to go
  ask thieves with [hidden? = false][
    ;if hidden? = false[
    set hide? false
  ]

  ask bikes[
    let leave (8 + random 2)
    let arrive (22 + random 2)

    if (ticks - birth-tick = arrive) or (ticks - birth-tick = arrive + 1)[
      set birth-tick ticks
      set show? true
      st
    ]
    if (ticks - birth-tick = leave) or (ticks - birth-tick = leave + 1)[
   ; or (ticks - birth-tick = leave + 1)[
      set show? false
      ht
    ]
  ]

  ;thieves move about if they are in the area
  if hide? = false[move-thief]

  if bikemarking? = true [
    bike-bikemarking
    ask bikes with [bikemarking? = true and hidden? = false][
      bikes-talk
    ]
  ]
  move-police

  ask thieves[
   ; if ticks - birth-tick > random 100 [die]
;    if ticks - birth-tick = localvariable [hide-turtle set hidden? true]
   ; if (ticks - birth-tick) mod 5 = 0  [ifelse hidden? = true [hide-turtle][show-turtle]]
    ;if ticks - birth-tick > localvariable + random 10 [show-turtle set hidden? false set birth-tick ticks]
     ; if(ticks - birth-tick) mod (random 3 + 1) = 0 [hide-turtle set hidden? true]
    if (ticks - birth-tick) = random 8 + 3 [hide-turtle set hidden? true]

      ;if (ticks - birth-tick) mod (random 4 + 1) = 0 [show-turtle set hidden? false]
    if (ticks - birth-tick) = 15 + random 5 [show-turtle set hidden? false set birth-tick ticks]
    if random 1000 = 5 [die]
    if random 1000 = 5 [thief-enter]
    if crime-probability < 0.1 [
      thief-elsewhere
    ]
    ]

  if count thieves < ((ratio-thieves * population-size ) - (ratio-thieves * population-size * 0.4)) [create-thieves random (ratio-thieves * population-size) [spawn-thief]]

    ;if ticks - birth-tick > localvariable2 + random 10 [show-turtle set hidden? false set birth-tick ticks]
  ;]
 if count bikes < ((ratio-bikes * population-size) - (ratio-bikes * population-size) * 0.15) [create-bikes (ratio-bikes * population-size * 0.1 ) [spawn-bike]]
;  ask thieves[
;    if crime-probability < 0.1 [
;      print "quit"
;      thief-elsewhere
;  ]
;  ]
tick

  if ticks = 6264 [stop]
end

to thief-patches
 ; ask patches with [count turtles-here > 1] [
    ;if count turtles-here > 1[
    ;ask patches in-radius 10 with [accessible?][
;  ask patches in-radius 10 with [(accessible?) and (count turtles-here > 1)][
  ask patches in-radius 5 with [(accessible?) and (count turtles-here > 1)][
;        if (any? thieves in-radius 5 with [accessible?])[
    if (any? thieves in-radius 5 with [accessible?])[
        set q-val-north 0
        set q-val-east 0
        set q-val-south 0
        set q-val-west 0
      ]
;        if (any? bikes in-radius 30 with [accessible?])[
            if (any? bikes in-radius 5 with [accessible?])[
        set q-val-north 10
        set q-val-east 10
        set q-val-south 10
        set q-val-west 10
      ]
;        if (any? policeofficer in-radius 30 with [accessible?])[
    if (any? policeofficer in-radius 5 with [accessible?])[
        set q-val-north -10
        set q-val-east -10
        set q-val-south -10
        set q-val-west -10
      ]
    ]
  ;]
  ;]

end

to police-patches
 ; ask patches with [count turtles-here > 1][
    ;if count turtles-here > 1[
      ;ask patches in-radius 10 with [accessible?][
;  ask patches in-radius 10 with [(accessible?) and (count turtles-here > 1)][
  ask patches in-radius 5 with [(accessible?) and (count turtles-here > 1)][
;        if (any? thieves in-radius 3 with [accessible?])[
    if (any? thieves in-radius 5 with [accessible?])[
        set q-val-north 10
        set q-val-east 10
        set q-val-south 10
        set q-val-west 10
      ]
;        if (any? bikes in-radius 30 with [accessible?])[
    if (any? bikes in-radius 5 with [accessible?])[
        set q-val-north 2
        set q-val-east 2
        set q-val-south 2
        set q-val-west 2
      ]
;        if (any? policeofficer in-radius 30 with [accessible?])[
    if (any? policeofficer in-radius 5 with [accessible?])[
        set q-val-north -10
        set q-val-east -10
        set q-val-south -10
        set q-val-west -10
      ]
    ]
;  ]
 ; ]
end

to move
  let current-xcor xcor
    let current-ycor ycor
    set heading ((random 4) * 90)
      let probability random-float 1
      ifelse (probability < 0.8)[
      ][
        ifelse (probability < 0.9)[
          set heading (heading + 90)]
        [set heading (heading - 90)]
      ]
     ; fd 10
  fd 10
      if pcolor = 28.6[
    bk 10
     ; bk 10
  ]
      set-qvalue current-xcor current-ycor heading xcor ycor
end

to move-thief
  ask thieves with [hidden? = false][
    move
    if crime-probability > 0.2[
    steal-bike
    ]
    sell-bike
  ;]
    thief-patches
  ]
end

;police need to check for stolen bikes with trackers
to move-police
  ;ifelse enforce? = true[
  ifelse (police-thief? = true) or (police-bike? = true) or (bikemarking? = true)[
  ask policeofficer[
    move
      if police-thief? = true [police-thief]
      ;policebike recover bicycles
      if (police-bike? = true) or (bikemarking? = true)[police-bike]
     ; if bikemarking? = true [police-recover]
  police-patches
  ]
  ]
  [ask policeofficer[hide-turtle]]

end

to steal-bike
 let randomnumber random-float 1
 let randomnumber2 random-float 1
;  ask bikes in-radius 6 with [(hidden? = false) and (shape = "bike") and (color = green) and (not stolen?)][
  ask bikes in-radius 2 with [(show? = true) and (shape = "bike") and (color = green) and (not stolen?)][
    ;if (shape = "bike") and (color = green) and (not stolen?)[
      if (desirability > randomnumber) and (security < randomnumber2)[
        set count-total count-total + 1
        hatch-bikes 1 [set stolen? true set color red]
        die
      ]
    ]
 ; ]
end

;bicycles are sold outside the area
to sell-bike
  ask bikes with [color = red and show? = true][
  ;ask bikes with [stolen? = true][
    ;if ticks - birth-tick > localvariable2 + random 10 [show-turtle set hidden? false set birth-tick ticks]
    ;bike is sold in the area
    if ticks - birth-tick = random 40 [hatch-bikes 1 die]
    ;bike is sold outside of the area
    if ticks - birth-tick > random 50 [die]
  ]
end

;thief comes to area
to thief-enter
  hatch-thieves 1 [spawn-thief]
end

;thieves detered from stealing/go to another area
to thief-elsewhere
  die
end

to police-thief
  ask thieves in-radius 5 with [hidden? = false][
    if random-float 1 > 0.5 [
    set crime-probability crime-probability - (crime-probability * 0.25)
    thieves-talk
    ;thieves go elsewhere/stop thieving here
    if crime-probability < 0.2 [die]
  ]
  ]
end

to police-bike
  ask bikes in-radius 50 with [show? = true and advised? = false][
    if police-bike? = true[
    let chance random-float 1
    if chance > 0.5 [set security security + 0.1 set advised? true]
    ]
    if bikemarking? = true[
    if any? bikes in-radius 50 with [(stolen? = true) and (marked? = true)][
        if random-float 1 > 0.7[
          let time ticks
          set recovered recovered + 1
          die
          if ticks = time + 48 [
      hatch-bikes 1 [spawn-bike set marked? true set security random-float 1 + 0.2]
            print "returned"
        ]
        ]
  ]
  ]
  ]
end


;bikes have bikemarking trackers- if recovered, possible to return to owner
to bike-bikemarking
  ask bikes with [(show? = true) and (random-float 1 < 0.02)][
    if random-float 1 < 0.02 [
    set marked? true
    ;set marked? true
    set desirability desirability - 0.1
    set security security + 0.05
  ]
  ]
end

;thieves talk to other thieves
to thieves-talk
  ask thieves in-radius 15 with [(hidden? = false) and (random-float 1 > 0.5)][
   ; if random-float 1 > 0.5 [set crime-probability crime-probability - 0.05]
    set crime-probability crime-probability - 0.05
  ]
end

;bike owners talk to other bike owners
to bikes-talk
  ask bikes in-radius 5 with [(hidden? = false) and (random-float 1 > 0.2)][
  ;  if random-float 1 > 0.2 [set marked? true print "advised"]
    set marked? true
  ]
end

to set-qvalue[current-xcor current-ycor current-heading new-xcor new-ycor]
  ; Q(s',a') optimal future value
  let optimal-f-val 0

  ;compute optimal future value
  ;finds the maximum reward possible (north, east, south, west)
  ask patch new-xcor new-ycor[
     set optimal-f-val (max (list q-val-north q-val-east q-val-south q-val-west))
  ]

  ;computed q-values
  ask patch current-xcor current-ycor[
    ;reward + 10, gamma 0.1 alpha 0.2
    ; thieves are a bit dumb so gamma is 0.1
    ; alpha 0.2 slow learning
    let alpha 0.8
    let gamma 0.8
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

;agent creation in gui
to spawn-police
  set shape "person"
  set color blue
  set size 20
  move-to one-of patches with [accessible?]
end

to spawn-bike
  set shape "bike"
  set color green
  set size 20
  set desirability random-float 1
  set security random-float 1
  set stolen? false
  set birth-tick ticks
  set marked? false
  set show? true
  set advised? false
  move-to one-of patches with [accessible?]
end

to spawn-thief
  setxy random-xcor random-ycor
  set shape "person"
  set color red
  set size 20
  set crime-probability random-float 1
  move-to one-of patches with [accessible?]
  set birth-tick ticks
  set hidden? false
end
