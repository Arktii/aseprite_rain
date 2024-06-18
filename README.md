# aseprite_rain
## Overview
This Aseprite script procedurally, and non-destructively, animates rain. 

![Example 1](https://github.com/Arktii/aseprite_rain/assets/72131971/4a192c47-e9b2-401a-88aa-aa7ff5bbf95b)

This is especially useful for scenes with very dense rain, as animating those by hand can be a lot of work. 

## Features
- Easily generate dense rain effects
- Create angled rain
- Customize raindrop appearance like color, drop length, speed, density
- Layered effects - create multiple layers of rain
- Non-destructive - animate rain on new layers

## How to Use
### 1. [Install](https://community.aseprite.org/t/aseprite-scripts-collection/3599)
Download Rain.lua and drop it into the scripts folder <br/>
![296418630-e0be082a-71df-4196-90ba-ac07684303d7](https://github.com/Arktii/aseprite_rain/assets/72131971/751bd94b-ae0d-4192-ac00-8195a502b25e)

### 2. Run the script (Rain)
![image](https://github.com/Arktii/aseprite_rain/assets/72131971/3d27ccb3-0269-4450-bb9c-5efcd857d4fb)

### 3. Customize the rain then click **Run**
See the section [Customization](#customization) below for a more detailed explanation on how each option affects the rain generated

> **Recommendation** Take time to choose a **color** that matches the scene. Reduce opacity if needed. <br/>
> The presets already provide flexible settings for almost any scene, but they don't modify the color at all.

![dialog box](https://github.com/Arktii/aseprite_rain/assets/72131971/9ca736b7-0cee-44b4-9aab-fa649488d51d)

> **Note** this may take a few seconds based on the options selected and the canvas size

> **Note** If you don't like the results, simply delete the generated layers and press **Run** again. There's a lot of randomness involved, so results will vary each time the script is run

### 4. Move layers around
The layers are generated on top of all other layers, but they can be moved around to form a foreground-background effect. 

> **Note** Each layer is drawn with a different opacity, so keep this in mind when choosing which layers go where. <br/><br/>
> If you want all your layers to have the same opacity, then set the *Layers* option to 1 then **Run** the script for each layer.

![layers](https://github.com/Arktii/aseprite_rain/assets/72131971/d3c7310a-2c0f-4f01-b2d1-0c2ffa0b6840)

## Examples
Drizzle <br/>
![Example 4](https://github.com/Arktii/aseprite_rain/assets/72131971/d88ccf70-49c9-4371-97b2-872d7f42a593)

Rainstorm <br/>
![Example 1](https://github.com/Arktii/aseprite_rain/assets/72131971/4a192c47-e9b2-401a-88aa-aa7ff5bbf95b)

Monsoon <br/>
![Example 3](https://github.com/Arktii/aseprite_rain/assets/72131971/4e8affe0-e088-4e88-a7b1-6488eea8e8fc)

Angled <br/>
![Example 2](https://github.com/Arktii/aseprite_rain/assets/72131971/824265d4-16c9-406e-93a2-8507a2e2c566)

## Customization
### Frames
The number of frames the animation will span. More frames will take longer to generate but will ensure more variation in the rain.

### Layers
The number of layers to be generated. Each layer is assigned a different opacity, this decreases with each layer, so the raindrops on layer *Rain 1* will be more visible than those on *Rain 4*.

If you don't want this effect, simply set *Layers* to 1, then **Run** the script for each layer.

### Presets
Pre-picked groups of settings that modify everything except color.

### Raindrop Color
This is the color of all raindrops on the first layer (*Rain 1*).  <br/>
Note that opacity will be lower for the other layers, but aside from that, the color is retained.

### Drop Length
The length of each raindrop in **number of pixels**

### Anti-Aliasing
Whether or not to use Anti-Aliasing when drawing the drops. <br/>
**Note** This looks better on big canvases.

### Speed
The speed of a raindrop in **pixels per frame**

### Angle
The angle of which the raindrop is travelling, in **degrees**, measured with respect to the **negative y-axis**.

### Spawn Rate
The number of drops spawned per frame (**drops per frame**).

### Length Randomness
The left input field is for maximum shrink (only negative) <br/>
The right input field is for the maximum extension (only positive). <br/>
Each drop is shrunk or extended by a random amount within the range specified.

### Angle Randomness
The left input field is for the maximum left rotation (only negative) <br/>
The right input field is for the maximum right rotation (only positive). <br/>
Both are measured in **degrees**. <br/>
The drop's angle will start with the angle specified in the **Angle** option, then it will be rotated by a random amount within the range specified.

## Algorithm Related Notes
Uses Xiaolin Wu's line algorithm to draw the raindrops with anti-aliasing https://en.wikipedia.org/wiki/Xiaolin_Wu%27s_line_algorithm <br>
Uses Bresenham's line algorithm to draw the raindrops without anti-aliasing https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm <br>
