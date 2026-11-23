# DSI-Approximate-Multiplier

This repository provides a VHDL implementation of the DSI approximate multiplier. The design divides the multiplier into three regions: Direct (D), Search (S), and Ignore (I). The Direct region is processed exactly, the Search region is approximated using shifts and addition, and the contribution of the least significant bits in the Ignore region is omitted.
VHDL implementation of the DSI approximate multiplier, following the hardware design described in the original paper and producing similar numerical results.


The algorithm first compares the two input operands. The larger operand is selected as the multiplier, and the smaller operand is selected as the multiplicand. The multiplier is then divided into three regions: the Direct region (D), the Search region (S), and the Ignore region (I).

1. **Direct region (D).** The bits in the Direct region are multiplied exactly by the multiplicand to obtain the contribution of this region to the final product.

2. **Search region (S).** The algorithm scans this region from its most significant bit toward its least significant bit. When it encounters the first bit set to `1`, it stores the indices of that bit and the adjacent bit, then stops searching. If all bits in the Search region are `0`, it stores the fallback index `n - s - d - 1`, where `n` is the operand bit width, `s` is the width of the Search region, and `d` is the width of the Direct region. The multiplicand is then left-shifted once for each stored index, using that index as the shift amount.

3. **Ignore region (I).** This region contains the lower-significance bits of the multiplier. Because these bits have a smaller effect on the final product, their contributions are omitted from the calculation.


## DSI Algorithm

### Five-Stages of the Operation

1. **SWAP**  
   Compare the two input operands. Assign the larger operand as the multiplier and the other as the multiplicand. Partition the multiplier into the D, S, and I regions.

2. **EXACT MULTIPLICATION**  
   Multiply the high-significance bits in the D region by the multiplicand. Preserve their original bit weights to obtain the exact contribution of the D region.

3. **SEARCH**  
   Scan the S region from its most significant bit toward its least significant bit. When the first `1` is found, record the indices of that bit and the adjacent bit. These two indices specify the amounts for two separate left shifts of the multiplicand. If all bits in S are `0`, use the single fallback shift amount specified in the original paper: `n - s - d - 1`, where `n` is the operand width, `s` is the width of S, and `d` is the width of D.

4. **APPROXIMATION**  
   Add the two shifted copies of the multiplicand to approximate the contribution of the S region. If the search uses the fallback shift amount, the single shifted value is the approximate contribution.

5. **ADD**  
   Add the exact contribution from D and the approximate contribution from S to produce the final approximate product.

### Configurable Accuracy

The width of the D region is configurable. Increasing it includes more high-significance bits in the exact multiplication and generally improves accuracy. Decreasing it reduces the portion computed exactly and allows for a more aggressive approximation. This setting lets the designer balance accuracy against hardware area and power consumption.

### Results

The numerical results evaluated in this implementation matched the corresponding values reported in the original paper. The evaluated configurations achieved low mean relative error, while the reductions in area and power consumption varied across configurations.
