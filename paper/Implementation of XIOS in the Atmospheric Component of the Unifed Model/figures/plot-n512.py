#!/usr/bin/env python

import matplotlib.pyplot as plt

xvals = [1,5,10,15]
yvals1 = [1520,1536,1596,1775]
yvals2 = [6.5,7.9,12.4,17]


fig, ax1 = plt.subplots()

color = 'tab:red'
ax1.set_xlabel('Ensemble size',  fontsize=18)
ax1.set_ylabel('Total time step time (s)',  fontsize=18, color=color)
ax1.plot(xvals, yvals1, 'ro', markersize=14)
ax1.axis([0, 16, 0, 2000])
ax1.tick_params(axis='y', labelcolor=color)


ax2 = ax1.twinx()

color = 'tab:blue'
ax2.set_ylabel('Mean output time step time (s)',  fontsize=18, color=color)
ax2.axis([0, 16, 0, 21])
ax2.plot(xvals, yvals2, 'b^', markersize=14)
ax2.tick_params(axis='y', labelcolor=color)


fig.tight_layout()
plt.savefig('ens-n512.pdf')
plt.show()
