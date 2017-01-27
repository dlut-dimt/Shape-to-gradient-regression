# Shape-to-gradient-regression
The Matlab source codes for Shape-to-gradient regression in "Explicit Shape Regression with Characteristic Number for Facial Landmark Localization "

## Training
Just run CN_training

## Testing
For testing, you need configure initializing shape with other alignment algorithm. In line 27 in `CN_test`

```matlab
 % here, requare a load initial shape
 res = initial_shape(:, :, i)
```

initial_shape is a 8-by-2-by-n matrix. n is the number of samples. 

or you could directly use groundtruth disturbed by rand value

```matlab
load dataset\test_set\groundtruth_test_lfpw.mat
initial_shape = cat(3, groundtruth_test_lfpw.FPoint);
initial_shape = initial_shape(flag_lfpw, :, :) + rand(8, 2, 10)*8;
```
