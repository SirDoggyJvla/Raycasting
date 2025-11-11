# Segment-segment interception
To calculate the z coordinates of P, we use the [intercept theorem](https://en.wikipedia.org/wiki/Intercept_theorem).

Consider the following diagram:
![segment-segment.svg](images/segment-segment.svg)

- P the intersect point of the ray and the object segment
- A and B the start and end points of the ray
- D and B the projections of P and C on the z level of A

We have the following relation:
$$
\frac{AD}{AB} = \frac{AE}{AC} = \frac{DE}{BC}
$$

We can derive from this the following formulas:
$$
DP = \frac{AD}{AB} BC
$$

With:
$$
\left\{ \begin{array}{lll}
BC = z_C - z_A\\
AD = \sqrt{(x_P - x_A)^2 + (y_P - y_A)^2}\\
AB = \sqrt{(x_C - x_A)^2 + (y_C - y_A)^2}\\
\end{array}\right.
$$

To finish:
$$
DP = \frac{\sqrt{(x_P - x_A)^2 + (y_P - y_A)^2}}{\sqrt{(x_C - x_A)^2 + (y_C - y_A)^2}} (z_C - z_A)
$$