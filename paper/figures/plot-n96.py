#!/usr/bin/env python

import matplotlib.pyplot as plt

xvals = [1,10,50, 100]
yvals1 = [119,130,162,197]
yvals2 = [0.94,1.38,2.88,5]

fig, ax1 = plt.subplots()

color = 'tab:red'
ax1.set_xlabel('Ensemble size', fontsize=18)
ax1.set_ylabel('Total time step time (s)', fontsize=18, color=color)
ax1.plot(xvals, yvals1, 'ro', markersize=14)
ax1.axis([-3, 103, 0, 215])
ax1.tick_params(axis='y', labelcolor=color)


ax2 = ax1.twinx()

color = 'tab:blue'
ax2.set_ylabel('Mean output time step time (s)', fontsize=18,color=color)
ax2.axis([-3, 103, 0, 6])
ax2.plot(xvals, yvals2, 'b^', markersize=14)
ax2.tick_params(axis='y', labelcolor=color)


plt.savefig('ens-n96.pdf')
plt.show()
