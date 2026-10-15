#!/usr/bin/env python3
"""Generate original tiny repeating textures and synthetic ambience; no asset dependencies."""
from pathlib import Path
import math
import random
import struct
import wave
from PIL import Image

ROOT = Path(__file__).resolve().parents[1] / 'assets'
rng = random.Random(441)
(ROOT / 'textures').mkdir(parents=True, exist_ok=True)
(ROOT / 'audio').mkdir(parents=True, exist_ok=True)

def texture(name, base, noise, pattern=None):
    im = Image.new('RGB', (64, 64))
    for y in range(64):
        for x in range(64):
            n = rng.randrange(-noise, noise + 1)
            color = tuple(max(0, min(255, c + n)) for c in base)
            if pattern:
                color = pattern(x, y, color)
            im.putpixel((x, y), color)
    im.save(ROOT / 'textures' / (name + '.png'))

texture('asphalt', (65, 67, 68), 14, lambda x,y,c: (34,36,36) if (x * 7 + y * 13) % 97 == 0 else c)
texture('concrete', (147, 143, 123), 9, lambda x,y,c: tuple(max(0,v-28) for v in c) if y in (0, 1) else c)
texture('plaster', (186, 183, 148), 8, lambda x,y,c: tuple(max(0,v-13) for v in c) if y % 16 == 0 else c)
texture('tile', (173, 176, 148), 5, lambda x,y,c: (68,81,73) if x % 16 == 0 or y % 16 == 0 else (tuple(max(0,v-25) for v in c) if (x//16+y//16)%2 else c))
texture('roof', (92, 98, 85), 6, lambda x,y,c: (44,56,52) if x % 8 < 2 else c)
texture('dirt', (69, 69, 47), 15)
texture('bark', (92, 82, 59), 12, lambda x,y,c: tuple(max(0,v-18) for v in c) if x%7==0 else c)

RATE = 22050
def wav(name, duration, fn):
    with wave.open(str(ROOT / 'audio' / (name + '.wav')), 'wb') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(b''.join(struct.pack('<h', int(max(-1,min(1,fn(i/RATE,i)))*32767)) for i in range(int(duration*RATE))))

wind_state = 0.0
def wind(t, i):
    global wind_state
    wind_state = wind_state * 0.98 + rng.uniform(-1,1) * 0.02
    fade = min(1, t / 0.3, (12-t) / 0.3)
    insects = math.sin(2*math.pi*3400*t) * max(0, math.sin(2*math.pi*2*t))**14 * (0.3+0.7*max(0,math.sin(2*math.pi*t/4)))
    return (wind_state * 0.8 + insects * 0.025) * fade
wav('night', 12, wind)
wav('hum', 4, lambda t,i: 0.06*math.sin(2*math.pi*60*t)+0.022*math.sin(2*math.pi*120*t)+rng.uniform(-0.004,0.004))
wav('door', 0.8, lambda t,i: (0.08*math.sin(2*math.pi*(160*t+45*t*t))+rng.uniform(-0.035,0.035))*math.sin(math.pi*t/0.8))
wav('footstep', 0.18, lambda t,i: (rng.uniform(-0.3,0.3)+math.sin(2*math.pi*85*t)*0.25)*math.exp(-t*35)*min(1,t*250))
print('Generated 7 textures and 4 sounds.')
