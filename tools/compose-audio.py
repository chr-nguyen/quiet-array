#!/usr/bin/env python3
"""Original score and environmental sounds. NumPy is only needed to regenerate WAVs.

After Hours: 64-second D minor/add9 ambient cue. No recordings, samples, or
third-party melodies. Circular event placement/reverb preserve loop tails.
"""
from pathlib import Path
import json
import wave
import numpy as np

ROOT = Path(__file__).resolve().parents[1] / 'assets' / 'audio'
ROOT.mkdir(parents=True, exist_ok=True)
SR = 44100
RNG = np.random.default_rng(1709)
TAU = 2 * np.pi
report = {}

def hz(midi):
    return 440 * 2 ** ((midi - 69) / 12)

def save(name, data, rate=SR, loop=False, peak=0.65):
    data = np.asarray(data, dtype=np.float64)
    data -= data.mean(axis=0)
    data *= peak / max(0.001, np.abs(data).max())
    pcm = np.round(data * 32767).astype('<i2')
    with wave.open(str(ROOT / (name + '.wav')), 'wb') as f:
        f.setnchannels(1 if pcm.ndim == 1 else pcm.shape[1])
        f.setsampwidth(2)
        f.setframerate(rate)
        f.writeframes(pcm.tobytes())
    report[name] = dict(seconds=round(len(data)/rate, 3), channels=1 if pcm.ndim == 1 else pcm.shape[1], peak_dbfs=round(20*np.log10(np.abs(data).max()),2), rms_dbfs=round(20*np.log10(np.sqrt(np.mean(data*data))),2))
    if loop:
        report[name]['seam_step'] = round(float(np.max(np.abs(data[0]-data[-1]))), 6)
    print(name, report[name])

def add_note(mix, start, midi, duration, gain, pan=0, kind='bell'):
    t = np.arange(int(duration*SR)) / SR
    f = hz(midi)
    attack = 1 - np.exp(-t * (18 if kind == 'bell' else 1.5))
    end = np.minimum(1, (duration - t) / 0.4)
    if kind == 'bell':
        env = attack * np.exp(-t / 1.8) * end
        tone = np.sin(TAU*f*t + 0.9*np.sin(TAU*f*2*t)*np.exp(-t*3))
        tone += 0.13*np.sin(TAU*f*3*t)*np.exp(-t*2)
    else:
        env = np.sin(np.pi * t / duration)**2
        tone = np.sin(TAU*f*t + 0.012*np.sin(TAU*0.4*t))
        tone += 0.23*np.sin(TAU*f*2.002*t) + 0.10*np.sin(TAU*f*3*t)
    note = tone * env * gain
    indices = (int(start*SR) + np.arange(len(t))) % len(mix)
    mix[indices, 0] += note * np.sqrt((1-pan)/2)
    mix[indices, 1] += note * np.sqrt((1+pan)/2)

length = 64
score = np.zeros((length*SR, 2))
# Long overlapping voicings: Dm(add9), Bbmaj7, Gm(add9), Asus4.
for start, chord in [(0,[38,53,57,64]), (16,[34,53,57,62]), (32,[31,50,57,58]), (48,[33,52,55,62])]:
    for j, note in enumerate(chord):
        add_note(score, start-4, note, 24, 0.052 if j else 0.085, (j-1.5)*0.3, 'pad')
# An original restrained motif with breathing space between phrases.
for start, phrase in [(3,[74,69,76,72]), (20,[77,74,69]), (36,[74,70,69,67]), (53,[76,74,69])]:
    for j, note in enumerate(phrase):
        add_note(score, start+j*1.7, note, 7, 0.070 if j==0 else 0.052, -0.28+j*0.16)
dry = score.copy()
for delay, gain in [(0.173,0.22),(0.337,0.17),(0.571,0.12),(0.911,0.09),(1.337,0.065),(2.103,0.04)]:
    score += np.roll(dry[:, ::-1], int(delay*SR), axis=0) * gain
save('after_hours', score, loop=True, peak=0.48)

# Periodic filtered noise has no discontinuity at the loop boundary.
def noise_loop(seconds, cutoff, low=0):
    count = int(seconds * SR)
    frequencies = np.fft.rfftfreq(count, 1/SR)
    spectrum = np.fft.rfft(RNG.normal(0,1,count))
    spectrum *= np.exp(-(frequencies / cutoff)**2)
    if low:
        spectrum *= 1-np.exp(-(frequencies/low)**2)
    out = np.fft.irfft(spectrum, n=count)
    return out / max(0.001, np.std(out))

t = np.arange(16*SR)/SR
wind = noise_loop(16, 850, 50) * (0.65 + 0.25*np.sin(TAU*t/16))
insects = np.sin(TAU*2784*t) * np.maximum(0,np.sin(TAU*3*t))**18
insects *= (0.15+0.85*np.maximum(0,np.sin(TAU*t/8))**2)
forest = np.column_stack((wind*0.045+insects*0.012, np.roll(wind, 1321)*0.045+np.roll(insects,550)*0.010))
save('forest', forest, loop=True, peak=0.38)

t = np.arange(8*SR)/SR
compressor = np.sin(TAU*60*t)*0.22 + np.sin(TAU*120*t)*0.08 + noise_loop(8,380,70)*0.028
compressor *= 0.95+0.05*np.sin(TAU*t/8)
save('compressor', compressor, loop=True, peak=0.32)

# An occasional distant metallic sign creak, gently enveloped, not a jump scare.
t = np.arange(2.8*SR)/SR
creak = np.sin(TAU*(178*t+17*np.sin(t*1.3))) + 0.3*np.sin(TAU*421*t)
creak *= np.sin(np.pi*t/2.8)**2 * np.exp(-t*0.8)
save('sign_creak', creak, peak=0.32)

for material in ['asphalt','tile']:
    t = np.arange(int(0.26*SR))/SR
    noise = RNG.normal(0,1,len(t))
    grit = np.convolve(noise, np.ones(5)/5, mode='same')
    attack = np.minimum(1,t/0.004)
    base = np.sin(TAU*(78 if material=='asphalt' else 145)*t)*np.exp(-t*32)
    sample = (grit*(0.21 if material=='asphalt' else 0.07)*np.exp(-t*22)+base*0.36)*attack
    if material == 'tile':
        sample += np.roll(sample, int(0.028*SR))*0.18
    sample *= np.minimum(1, (0.26-t)/0.02)
    save('step_'+material, sample, peak=0.56)

(ROOT / 'audio-report.json').write_text(json.dumps(report, indent=2)+'\n')
print('Original audio generated; report saved.')
