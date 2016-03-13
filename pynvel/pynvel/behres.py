"""
Created on Mar 7, 2016

@author: THAREN
"""

import matplotlib.pyplot as plt
import numpy as np

def info(x): print('INFO: {}'.format(x))
def warn(x): print('WARNING: {}'.format(x))

def fit_a0(hd_pairs, fdib, fht, tht):
    hup = float(tht) - float(fht)
#     print(hup)
    a0 = []
    for h, d in hd_pairs:
        h = h - fht
#         print(h)
        x = (hup - h) / hup
#         print(x)
        b = (d - fdib * x) / (d * (1 - x))
#         print(b)
        a0.append(b)

    bsum = sum(a0)
    bavg = bsum / len(a0)

    return bavg

# hd_pairs = [(70.0, 8.0 * .919)]
# print(fit_a0(hd_pairs, 24.4 * .87, 17.3, 99))

class BehresHyperbola(object):
    """
    Implementation of the Behre's hyperbola method of for stem taper and volume.
    """

    def __init__(self
            , dbh, total_ht, species='NA'
            , form_class=80.0, form_ht=33.6
            , bark_ratio=0.90
            , breast_ht=4.5, stump_ht=1.0
            , a0=0.62, top_ht=None, top_dib=None):
        """
        Initialize the Behre's hyperbola class
        
        Args:
            dbh (float): Diameter outside bark at breast height
            total_ht (float): Total height from root collar to tip
            species (str): (optional) Species abbreviation
            form_class (float): Girard form class
            form_ht (float): Height at which form class represents
            bark_ratio (float): Double bark thickness ratio
            breast_ht (float): Height above the root collar represented by DBH 
            stump_ht (float): Stump height abot the root collar
            a0 (float): Behre's tree form coefficient
            top_ht (float): Height where top_dib is measured
            top_dib (float): Upper stem DIB
        """
        self.dbh = dbh
        self.total_ht = total_ht
        self.species = species
        self.form_class = form_class
        self.form_ht = form_ht
        self.bark_ratio = bark_ratio
        self.breast_ht = breast_ht
        self.stump_ht = stump_ht
        self.a0 = a0
        self.top_ht = top_ht
        self.top_dib = top_dib

        self.error_codes = []

        if self.bark_ratio < self.form_class * 0.01:
            warn('Bark ratio is less than form class, '
                    'setting bark_ratio=form_class/100.')
            self.bark_ratio = self.form_class * 0.01
            self.error_codes.append(1)

        self.bh_dib = self.dbh * self.bark_ratio
        self.fh_dib = self.dbh * self.form_class * 0.01
        self.b0 = 1.0 - self.a0
        self.ht_upper = self.top_ht - self.form_ht

        self.at = self.a0
        self.bt = self.b0
        self.t = 0.0

#         if top_ht xor top_dib:
#             warn('Top height and top DIB must be specified together.')

        if not top_ht and top_dib:
            self.top_ht = self.total_ht
            self.top_dib = 0.0

#        # Compute a0 by forcing it through the merch top
        # Compute T, AT, & BT per Bell & Dilworth
        self.t = self.top_dib / self.fh_dib
        self.at = self.a0 / (1 - self.a0 * self.t)
        self.bt = 1.0 / (1 - self.t) - self.at

        print(self.top_dib, self.fh_dib, self.t, self.at, self.bt)
        if not self.a0:
            self.error_codes.append(2)
            warn('Parameter a0 is required:{}'.format(self.a0))

        if self.a0 > 1.0:
            self.error_codes.append(3)
            warn('Parameter a0 is greater than 1.0: {:.3f}'.format(self.a0))

        if self.a0 < 0.0:
            self.error_codes.append(3)
            warn('Parameter a0 is less than 0.0: {:.3f}'.format(self.a0))

    def dib(self, ht, est_swell=False):
        """
        Return the diameter inside bark at a given height.
        
        For `ht >= form_ht` DIB is estimated using the Behre's hyperbola method.
        For `ht >= breast_ht` DIB is estimated by linear interpolation between
            fh_ht and bh_dib.
        
        Swell below breast height can optionally be estimated.
        
        Args:
            ht (float): Height above the root collar
            est_swell (bool): If True, estimate swell below breast height
            
        Returns:
            float: DIB @ ht
        """

#         if ht >= self.total_ht:
#             d = 0.0
#
#         elif ht >= self.form_ht:
#             # Use Behre's above the form height
# #             l = (self.total_ht - ht) / self.ht_upper
# #             dr = l / (self.b0 + self.a0 * l)
# #             d = self.fh_dib * dr

        l = (self.top_ht - ht) / self.ht_upper
#             print(l, self.t)
        dr = l / (self.at * l + self.bt) + self.t
        d = self.fh_dib * dr

#         elif (ht >= self.breast_ht) or not est_swell:
#             # Linear interpolation between breast height and form height
#             # Extend to ground if not estimating swell
#             d = self._interp_base_dib(ht)
#
#         elif ht >= self.stump_ht:
#             x = self.breast_ht - ht
#             d = self.bh_dib * 1.035 ** x
#
#         else:
#             x = self.breast_ht - ht
#             d = self.bh_dib * 1.05 ** x

        return d

    def smalians_vol(self, d1, d2, l):
        """
        Return the cubic volume of a segment, computed using Smalian's rule.
        
        Args:
            d1,d2 (float): End diameters of the segment
            l (float): Length of the segment
        
        Returns:
            float: Cubic volume of the segment
        """
        v = 0.002727077 * (d1 ** 2 + d2 ** 2) * l
        return v

    def _interp_base_dib(self, ht):
        """
        Return a DIB interpolated between the form height and breast height.
        
        Args:
            ht (float): Height at which to interpolate DIB
            
        Returns:
            float: Estimated DIB at ht
        """
        y = self.bh_dib - self.fh_dib
        x = self.form_ht - self.breast_ht
        m = y / x

#         print(y, x, m)

        d = self.fh_dib + m * (self.form_ht - ht)
        return d

    def segment_volume(self, ht1, ht2):
        """
        Return the cubic volume of a segment of the bole
        
        Args:
            ht1,ht2 (float): Heights representing the end points of the segment
        """
        ht1 = min(ht1, ht2)
        ht2 = max(ht1, ht2)
        d1 = self.dib(ht1)
        d2 = self.dib(ht2)
        l = ht2 - ht1
        v = self.smalians_vol(d1, d2, l)
        return v

    def ht_range(self, hmin, hmax, incr=1.0):
        h = hmin
        while h < hmax:
            yield h
            h += incr

        yield hmax

    def find_dib(self, target_dib, tolerance=0.1, max_iter=10):
        """
        Return the height where a target DIB occurs.
        
        The height along the bole is found by binary search. The search
        will progress until the tolerance is met or the maximum number of
        iterations is reached.
        
        Args:
            target_dib (float): Diameter inside bark to locate
            tolerance (float): Maximum Absolute difference in DIB
            max_iter (int): Maximum number of search iterations
        
        Returns:
            float: Height along the bole where the target DIB occurs
        """
        # TODO: Allow for butt swell in the search instead of the bh_dib limit.
#         if target_dib > self.bh_dib:
#             return self.breast_ht

        # Find the target DIB by binary search
        low = 0.0
        high = self.total_ht
        delta = tolerance + 1

#         print(' i,   lower,   upper,     mid,     dib,   delta,  s')
        i = 0
        # search until the tolerance is met or maximum iterations is exceeded
        while delta > tolerance and i < max_iter:

            # incrementally divide the search range in half
            mid = (high + low) * 0.5
            # Compute the DIB at the new mid point
            dib = self.dib(mid)
            delta = abs(dib - target_dib)

#             fmt = '{:2d},{:8.3f},{:8.3f},{:8.3f},{:8.3f},{:8.3f},{:3s}'

            # Working along the bole, assume monotonically decreasing DIB
            #     from base to tip.
            # If mid DIB > target DIB, move the search up from the mid point
            # Otherwise continue down from the mid point
            if dib > target_dib:
                low = mid
#                 print(fmt.format(i, low, high, mid, dib, delta, '->'))
            else:
                high = mid
#                 print(fmt.format(i, low, high, mid, dib, delta, '<-'))

            i += 1

        return mid

    def merch_cuft(self, hts=None, top_dib=5.0, incr=2.0):
        """
        Return the cubic volume between the stump and a minimum dib.
        
        Args:
            hts (float): Optional list of segment end heights
            top_dib (float): Minimum DIB if hts is not provided
            incr (float): Length increment if hts is not provided.
        
        Returns:
            float: Estimated cubic volume
        """
        merch_ht = self.find_dib(top_dib)
        hts = list(self.ht_range(self.stump_ht, merch_ht, 16.3))
        if not hts:
            merch_ht = self.find_dib(top_dib)
            hts = list(self.range(self.stump_ht, merch_ht))

        v = self.cuft(hts)
        return v

    def cuft(self, hts=None, incr=2.0, with_stump=False):
        """
        Return total cubic volume computed by segmentation.
        
        Args:
            hts (float): List of segment heights to use for volume calculation
            incr (float): Segment length to use for calculation if `hts is None`
        
        Returns:
            float: Total cubic volume
        """
        if not hts:
            # Get a list of segment heights from ground to tip
            if with_stump:
                b = 0.0
            else:
                b = self.stump_ht
            hts = list(self.ht_range(b, self.total_ht, incr))

        else:
            # Height order must be monotonic
            hts.sort()

        # list DIBs for each segment height
        dib = [self.dib(h) for h in hts]

        # Sum the volume for each segment
        v = 0
        for i in range(1, len(hts)):
            vi = self.smalians_vol(dib[i - 1], dib[i], hts[i] - hts[i - 1])
#                 print(vi)
            v += vi

        return v

def test():
    b = BehresHyperbola(16.0, 88
            , top_dib=6 * .92, top_ht=68
            , form_class=84, form_ht=17.3
            , bark_ratio=0.92, a0=0.5047965)
    ht = [0.0, 1.0, b.breast_ht, b.form_ht, b.form_ht + 16.3, 41.0, b.top_ht, b.total_ht]
    ht = np.array(ht)
    f = np.vectorize(b.dib)
    dib = f(ht)

    print(' ht: ' + ', '.join('{:6.3f}'.format(h) for h in ht))
    print('dib: ' + ', '.join('{:6.3f}'.format(d) for d in dib))
    print(b.bh_dib)
    print(b.fh_dib)
    print(b.cuft())  # hts=ht))
    print(b.merch_cuft(top_dib=5.0))

    plt.plot(dib * 0.5, ht)
    plt.plot(dib * -0.5, ht)
    plt.plot(dib / b.bark_ratio * 0.5, ht)
    plt.plot(dib / b.bark_ratio * -0.5, ht)
    plt.axhline(b.breast_ht, linestyle='dashed', color='gray')
    plt.axhline(b.form_ht, linestyle='dashed', color='gray')
    plt.axhline(b.stump_ht, linestyle='dashed', color='gray')
    plt.axhline(b.top_ht, linestyle='dashed', color='gray')
    plt.show(block=True)
    f = plt.gcf()
    f.set_size_inches(3, 10)

def test_vol():
    b = BehresHyperbola(18, 120, form_class=80, form_ht=33.6)
    print(b.cuft())

#     merch_ht = b.find_dib(5.0, tolerance=0.25, max_iter=50)
#     print(merch_ht)
#     hts = list(b.ht_range(b.stump_ht, merch_ht, 16.3))
#     print(hts)
#     print(b.cuft(hts))
    print(b.merch_cuft())

def test_find_dib():
    b = BehresHyperbola(18, 120, form_class=80, form_ht=33.6)
    ht = b.find_dib(18.0 * .90, tolerance=0.000001, max_iter=500)
    print(ht)

test()
# test_vol()
# test_find_dib()
