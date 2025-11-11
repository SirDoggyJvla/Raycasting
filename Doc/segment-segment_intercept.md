# Segment-segment interception
To calculate the z coordinates of P, we use the [intercept theorem](https://en.wikipedia.org/wiki/Intercept_theorem).

Consider the following diagram:
![segment-segment.svg](images/segment-segment.svg)

- P the intersect point of the ray and the object segment
- A and B the start and end points of the ray
- C and D the start and end points of the object segment
- E and F the projections of P and B on the z level of A

We have the following relation:
$$
\frac{AF}{AE} = \frac{AP}{AB} = \frac{FP}{EB}
$$

We can derive from this the following formulas:
$$
FP = \frac{AF}{AE} EB
$$

With:
$$
\left\{ \begin{array}{lll}
EB = z_B - z_A\\
AF = \sqrt{(x_P - x_A)^2 + (y_P - y_A)^2}\\
AE = \sqrt{(x_B - x_A)^2 + (y_B - y_A)^2}\\
\end{array}\right.
$$

To finish:
$$
FP = \frac{\sqrt{(x_P - x_A)^2 + (y_P - y_A)^2}}{\sqrt{(x_B - x_A)^2 + (y_B - y_A)^2}} (z_B - z_A)
$$