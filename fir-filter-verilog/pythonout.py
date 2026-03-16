
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import firwin


fs = 10000
cutoff = 1000
taps = 101
samples = 500

scale = 2**14   # for Q(2,14)

freqs = [950,1100,2000]




h = firwin(taps, cutoff/(fs/2))

h_fixed = np.round(h*scale).astype(int)


np.savetxt("coefficients.txt",h_fixed,fmt="%d")

print("coefficients saved")


t = np.arange(samples)/fs

signals = {}

for f in freqs:
    
    s = np.sin(2*np.pi*f*t)
    
    s_fixed = np.round(s*scale).astype(int)
    
    signals[f] = s_fixed
    
    name = "signal_"+str(f)+"Hz.txt"
    np.savetxt(name,s_fixed,fmt="%d")
    
    print("saved",name)

def fir_filter(x,h):
    
    N = len(h)
    y = np.zeros(len(x))
    
    for n in range(len(x)):
        
        acc = 0
        
        for k in range(N):
            
            if(n-k >= 0):
                acc = acc + x[n-k]*h[k]
        
        y[n] = acc >> 14
    
    return y


outputs = {}

for f in freqs:
    
    y = fir_filter(signals[f],h_fixed)
    
    outputs[f] = y
    
    name = "python_output_"+str(f)+"Hz.txt"
    np.savetxt(name,y,fmt="%d")
    
    print("saved",name)



