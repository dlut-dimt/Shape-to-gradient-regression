function [num] = charnumber3( p )
% function to calculate value of CN_3 
x6 = 1; y6 = 0;m = 0;
a = p(:,1); [m,ind] = max(a(:));[row,col] = ind2sub(size(a),ind);
x5 = p(row,col); y5 = p(row,col+1);
[m,ind] = min(a(:));[row,col] = ind2sub(size(a),ind);
x1 = p(row,col); y1 = p(row,col+1);
[m] = median(a(:));row = find(m == a,1);
x3 = p(row,col);y3 = p(row,col+1);
x2 = x1; x2 = (y5-y6)/(x5-x6)*(x1-x6)+y6;
x4 = x1; y4 = (y3-y6)/(x3-x6)*(x1-x6)+y6;
c1 = (((y1-y6)-(y5-y6)/(x5-x6)*(x1-x6))/((x1-x6)*((y3-y6)/(x3-x6)-(y5-y6)/(x5-x6))))/(1-(((y1-y6)-(y5-y6)/(x5-x6)*(x1-x6))/((x1-x6)*((y3-y6)/(x3-x6)-(y5-y6)/(x5-x6)))));
c2 = ((x1*y3*(x3-x6)-x3*(y3-y6)*(x1-x6)-x3*y6*(x3-x6))/(x1*y6*(x3-x6)-x6*(y3-y6)*(x1-x6)-x6*y6*(x3-x6)))/((x3-((x1*y3*(x3-x6)-x3*(y3-y6)*(x1-x6)-x3*y6*(x3-x6))/(x1*y6*(x3-x6)-x6*(y3-y6)*(x1-x6)-x6*y6*(x3-x6)))*x6)/x1);
c3 = ((x5-((x1*y5*(x5-x6)-x5*(y5-y6)*(x1-x6)-x5*y6*(x5-x6))/(x1*y6*(x5-x6)-x6*(y5-y6)*(x1-x6)-x6*y6*(x5-x6)))*x6)/x1)/((x1*y5*(x5-x6)-x5*(y5-y6)*(x1-x6)-x5*y6*(x5-x6))/(x1*y6*(x5-x6)-x6*(y5-y6)*(x1-x6)-x6*y6*(x5-x6)));
num = c1*c2*c3;
end