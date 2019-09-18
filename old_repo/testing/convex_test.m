clear; close all; clc

x = 0:0.01:10;
d = 2;
mu = 5;

f = @(x) -exp(-d*(x-mu).^2);

df = @(x) -2*d*(x-mu).*f(x);

d2f = @(x) (-2*d + 4*d^2*(x-mu).^2).*f(x);

subplot(3,1,1)
plot(x, f(x))
grid on;
subplot(3,1,2)
plot(x, df(x))
grid on;
subplot(3,1,3)
plot(x, d2f(x))
grid on;