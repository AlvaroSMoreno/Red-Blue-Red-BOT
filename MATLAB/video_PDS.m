clear all;
clc;

point = [0 0];

state = 'r';
v= videoinput('winvideo',2,'YUY2_320x240');
flushdata(v);
set(v, 'ReturnedColorSpace', 'rgb');
set(v, 'TriggerRepeat', Inf);
figure;
set(gcf, 'doublebuffer', 'on');

%port_name = input('Ingrese el puerto donde esta corriendo el
%arduino...\nEjemplo: COM5');
%baud_rate = input('Ingrese el baudrate que usa su dispositivo\nEjemplo: 9600');
%serialport = serial(port_name,'BAUD', baud_rate);
serialport = serial('COM5','BAUD', 9600);
fopen(serialport);

start(v)
while(v.FramesAcquired < 1000 || 1<2)

flushdata(v);
    
data = getsnapshot(v);
r= imsubtract(data(:,:,1),rgb2gray(data));
b = imsubtract(data(:,:,3),rgb2gray(data));
r = medfilt2(r, [4 4]);
b = medfilt2(b, [4 4]);
red = im2bw(r,0.2);
blue = im2bw(b, 0.35);

rojo = sum(red(:));
azul = sum(blue(:));

red = bwareaopen(red, 55);
blue = bwareaopen(blue, 55);

s1 = regionprops(red, 'centroid', 'area');
centroids1 = cat(1, s1.Centroid);   %centroids for red objects
area_red = cat(1, s1.Area);

s2 = regionprops(blue, 'centroid', 'area');
centroids2 = cat(1, s2.Centroid);   %centroids for blue objects
area_blue = cat(1, s2.Area);

%POINT OF REFERENCE
area_bherga_r = [0 0];
for i = 1:length(area_red)
    if(area_bherga_r(1) < area_red(i))
        area_bherga_r = [area_red(i) i];
    end;
end;

area_bherga_b = [0 0];
for i = 1:length(area_blue)
    if(area_bherga_b(1) < area_blue(i))
        area_bherga_b = [area_blue(i) i];
    end;
end;


%Hasta aqui se tiene el area mas grande, es decir, los bloques
%inferiores...

point_r = [0 0];
point_b = [0 0];

distance_red = [];
distance_blue = [];

if(length(centroids2) ~= 0 & length(centroids1) ~= 0)
    point_r = [centroids1(area_bherga_r(2),1) centroids1(area_bherga_r(2),2)];
    point_b = [centroids2(area_bherga_b(2),1) centroids2(area_bherga_b(2),2)];
    
    if(point_r(2) < point_b(2))
      point(1) = point_r(1);
      point(2) = point_r(2)-((point_b(2) - point_r(2))/2);
    else
      point(1) = point_b(1);
      point(2) = point_b(2)-((point_r(2) - point_b(2))/2);
    end;

    point = [155 200];
% DISTANCE
%Ignore all the negative distances to focus in the small objects falling
%then measure the distance between y cord. from the point to the centroid
%of the object, and store the minimum value...
array_size_r = size(centroids1);
arr_r = array_size_r(1);

array_size_b = size(centroids2);
arr_b = array_size_b(1);


for i = 1:arr_r
    distance_red = [distance_red (point(2)-centroids1(i,2))];
end;

for i = 1:arr_b
    distance_blue = [distance_blue (point(2)-centroids2(i,2))];
end;

end;

%Minimum Value...
min_value_red = Inf;
min_value_blue = Inf;
for i = 1:length(distance_red)
    if(distance_red(i) >= 0 && distance_red(i) < min_value_red)
        min_value_red = distance_red(i);
    end;
end;

for i = 1:length(distance_blue)
    if(distance_blue(i) >= 0 && distance_blue(i) < min_value_blue)
        min_value_blue = distance_blue(i);
    end;
end;

min_value_red
min_value_blue
% %Changing state...
if(min_value_red < min_value_blue)
    %disp('Rojo!!!');
    if(state ~= 'r')
        fprintf(serialport, 'a');
        disp('Rojo: Tocar pantalla...');
        state = 'r';
    end;
else
    %disp('Azul!!!');
    if(state ~= 'b')
        fprintf(serialport, 'a');
        disp('Azul: Tocar pantalla...');
        state = 'b';
    end;
end;

subplot(1,4,1);
imshow(data);
title('Original');
drawnow();
subplot(1,4,2);
imshow(red);
if(arr_r > 1)
    hold on;
    plot(centroids1(:,1), centroids1(:,2), 'r*');
    hold off;
end;
title('Deteccion de rojo');
drawnow();
subplot(1,4,3);
imshow(blue);
if(arr_b > 1)
    hold on;
    plot(centroids2(:,1), centroids2(:,2), 'b*');
    hold off;
end;
title('Deteccion de azul');
subplot(1,4,4);
imshow(data);
hold on;
%plot(point(1), point(2), 'mo');
plot(point(1), point(2), 'mo');
hold off;
title('Punto de Referencia');
drawnow();

flushdata(v);

end;
stop(v);

flushdata(v);
fclose(serialport);