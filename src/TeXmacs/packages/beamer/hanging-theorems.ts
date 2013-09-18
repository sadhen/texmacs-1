<TeXmacs|1.0.7.19>

<style|source>

<\body>
  <active*|<\src-title>
    <src-package|framed-theorems|1.0>

    <\src-purpose>
      A style package for ornamented theorems.
    </src-purpose>

    <src-copyright|2013|Joris van der Hoeven>

    <\src-license>
      This software falls under the <hlink|GNU general public license,
      version 3 or later|$TEXMACS_PATH/LICENSE>. It comes WITHOUT ANY
      WARRANTY WHATSOEVER. You should have received a copy of the license
      which the software. If not, see <hlink|http://www.gnu.org/licenses/gpl-3.0.html|http://www.gnu.org/licenses/gpl-3.0.html>.
    </src-license>
  </src-title>>

  <assign|hang-length|0.15em>

  <\active*>
    <\src-comment>
      Framed theorems
    </src-comment>
  </active*>

  <assign|enunciation-sep|>

  <assign|enunciation-name|<macro|which|<with|color|<value|bg-color>|font-series|bold|<arg|which>>>>

  <assign|unframed-render-enunciation|<value|render-enunciation>>

  <assign|render-enunciation|<\macro|which|body>
    <\ornament>
      <surround|<resize|<with|ornament-color|<value|ornament-extra-color>|<ornament|<resize|<arg|which>||<minus|1b|1hang>||<plus|1t|1hang>>>>|<plus|1hang|<value|ornament-hpadding>|<value|ornament-border>>|<plus|1b|1hang>||<minus|<minus|1t|1hang>|<plus|<value|ornament-vpadding>|<value|ornament-border>>>>
      |<right-flush>|<arg|body>>
    </ornament>
  </macro>>
</body>

<\initial>
  <\collection>
    <associate|preamble|true>
  </collection>
</initial>