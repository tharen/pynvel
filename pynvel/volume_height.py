

import numpy as np
import pynvel

def calc_volume_height(eq, dbh, tot_ht, vol_ht=None, fc=None, incr=4.0, **kwargs):
  """
  Return cubic volume to a specific stem height.

  NOTE: Subroutine TCUBIC in profile.f performs the same procedure,
        however when total height==volume height the returned
        volumes are not identical.

  Args:
  eq - NVEL volume equation ID
  dbh - Diameter at breast height
  tot_ht - Total tree height
  fc - Form class
  vol_ht - Stem height to sum volume to
  kwargs - Additional keyword arguments for pynvel.calc_dib
  """

  if vol_ht>tot_ht:
    raise ValueError(f'Volume height must not exceed total height: {vol_ht:.2f}>{tot_ht:.2f}')

  ht_incr = np.arange(1, vol_ht+incr, incr)
  ht_incr[-1] = vol_ht
  vol = np.zeros(ht_incr.shape[0])
  dib = np.zeros(ht_incr.shape[0])

  # Mimic profile.f
  # cylinder volume for 1 ft stump
  # smalians for 4 ft segments from stump to tip
  ht0 = ht_incr[0]
  d0 = pynvel.calc_dib(volume_eq=eq, dbh_ob=dbh, total_ht=tot_ht, form_class=fc, stem_ht=ht0, **kwargs)
  vol[0] = d0*d0*0.005454154 * ht0
  dib[0] = d0
  for i, ht1 in enumerate(ht_incr[1:]):
    d1 = pynvel.calc_dib(volume_eq=eq, dbh_ob=dbh, total_ht=tot_ht, form_class=fc, stem_ht=ht1, **kwargs)
    # smal = (d0*d0*0.005454154 + d1*d1*0.005454154)/2 * (ht1-ht0)
    smal = 0.00272708 * (d0*d0+d1*d1) * (ht1-ht0)
    vol[i+1] = smal
    dib[i+1] = d1

    # print(round(d0,2),round(d1,2),round(ht0,2),round(ht1,2),round(smal,2),round(vol.sum(),0))

    ht0 = ht1
    d0 = d1

#   for i in range(vol.shape[0]):
#     print(ht_incr[i].round(2), dib[i].round(2), vol[i].round(2), vol[:i+1].sum().round(3))

  return vol.sum()