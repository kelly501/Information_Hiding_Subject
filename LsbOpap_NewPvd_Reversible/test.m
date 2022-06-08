clc; clear all;
Img = imread ('misc/4.2.03.tiff');
Cover =double(rgb2gray(Img));
BW = uint8(edge(Cover,'Canny'));
[rows cols] = size(Cover);
StegoB = Cover; %黑格
StegoW = Cover; %白格
d = [0,rows*cols];
di = 1 ;% 差值d的index
da = zeros(rows, cols); % d matrix 是否為edge
B = zeros(rows, cols);
W = zeros(rows, cols);
P = zeros(rows, cols);

secret = randi([0, 1], 1, 512 * 512 * 10);
index = 1;
c = 0;  % count


for i = 1:rows
  for j = 1:cols
      if BW(i,j) == 1 
        if i == 1 && j == 1 
            x = abs(Cover(i+1,j)-Cover(i,j+1));
        elseif i == 1 && j == cols
            x = abs(Cover(i,j-1)-Cover(i+1,j));
        elseif i == rows && j == 1
            x = abs(Cover(i,j+1)-Cover(i-1,j));
        elseif i == rows && j == cols
            x = abs(Cover(i,j-1)-Cover(i-1,j));
        elseif i == 1 && j ~= 1 && j ~= cols
            x = [abs(Cover(i,j-1)-Cover(i,j+1)),abs(Cover(i,j-1)-Cover(i+1,j)),abs(Cover(i,j+1)-Cover(i+1,j))]; 
        elseif i == rows && j ~= 1 && j ~= cols
            x = [abs(Cover(i,j-1)-Cover(i+1,j)),abs(Cover(i,j-1)-Cover(i-1,j)),abs(Cover(i,j+1)-Cover(i-1,j))];
        elseif i ~= 1 && i ~= rows && j == 1
            x = [abs(Cover(i-1,j)-Cover(i+1,j)),abs(Cover(i,j+1)-Cover(i+1,j)),abs(Cover(i,j+1)-Cover(i-1,j))];
        elseif i ~= 1 && i ~= rows && j == cols
            x = [abs(Cover(i-1,j)-Cover(i+1,j)),abs(Cover(i,j-1)-Cover(i-1,j)),abs(Cover(i,j-1)-Cover(i+1,j))];
        else
            x = [abs(Cover(i-1,j)-Cover(i+1,j)),abs(Cover(i,j-1)-Cover(i,j+1)),abs(Cover(i,j+1)-Cover(i+1,j)),abs(Cover(i,j+1)-Cover(i-1,j)),abs(Cover(i,j-1)-Cover(i+1,j)),abs(Cover(i,j-1)-Cover(i-1,j))];
        end
        d(di) = max(x);
        di = di + 1;
        da(i,j) = max(x);
      end
  end
end

dm = median(sort(d)); %差值排序後取中位數
% k=floor(log2(dm));
k=3;
for i = 1:rows   % 以上下左右差值判斷法取代canny
    for j = 1:cols
        if da(i,j) >= dm
            da(i,j)=1;
        else
            da(i,j)=0;
        end
    end
end


% 黑格 白格
for i=1:rows
    if mod(i,2) == 1
       for j = 1:2:cols
           B(i,j) = 1;
       end
       for j = 2:2:cols
           W(i,j) = 1;
       end
    else
        for j = 1:2:cols
           W(i,j) = 1;
       end
       for j = 2:2:cols
           B(i,j) = 1;
       end
    end    
end
% 預測像素
for i = 1:rows
   for j = 1:cols
       if i == 1 && j == 1 
           p = (Cover(i+1,j)+Cover(i,j+1))/2;
       elseif i == 1 && j == cols
           p = (Cover(i,j-1)+Cover(i+1,j))/2;
       elseif i == rows && j == 1
           p = (Cover(i-1,j)+Cover(i,j+1))/2;
       elseif i == rows && j == cols
           p = (Cover(i-1,j)+Cover(i,j-1))/2;
       elseif i == 1 && j ~= 1 && j ~= cols
           p = (Cover(i,j-1)+Cover(i,j+1)+Cover(i+1,j))/3; 
       elseif i == rows && j ~= 1 && j ~= cols
           p = (Cover(i-1,j)+Cover(i,j-1)+Cover(i,j+1))/3;
       elseif i ~= 1 && i ~= rows && j == 1
           p = (Cover(i+1,j)+Cover(i-1,j)+Cover(i,j+1))/3;
       elseif i ~= 1 && i ~= rows && j == cols
           p = (Cover(i-1,j)+Cover(i+1,j)+Cover(i,j-1))/3;
       else
           p = (Cover(i+1,j)+Cover(i-1,j)+Cover(i,j+1)+Cover(i,j-1))/4;
       end
       if p<=Cover(i,j)
           p=ceil(p);
       else
           p=floor(p);
       end
       P(i,j) = p;
   end
end

% LSB+OPAP(non-edge) PVD(edge)
for i = 1:rows
   for j = 1:cols
       if B(i,j) == 1 && da(i,j) == 0  %黑格且non-edge
           s = 0;
           for l = 1:k
               s = s + secret(index) * (2 ^ (k - l));
               index=index+1;
               c=c+1;
           end
           StegoB(i, j) = Cover(i, j) - mod(Cover(i, j), 2 ^ k) + s;
           StegoB(i,j)=OPAP(Cover(i,j),StegoB(i,j),k);
       elseif B(i,j) == 1 && da(i,j) == 1
           [StegoB(i,j),m]= PVD_Shiao(Cover(i,j),P(i,j),k,secret(index:end));
           index=index+m;
           c=c+m;
       elseif W(i,j) == 1 && da(i,j) == 0
           s = 0;
           for l = 1:k
               s = s + secret(index) * (2 ^ (k - l));
               index=index+1;
               c=c+1;
           end
           StegoW(i,j) = Cover(i, j) - mod(Cover(i, j), 2 ^ k) + s;
           StegoW(i,j)=OPAP(Cover(i,j),StegoW(i,j),k);
       elseif W(i,j) == 1 && da(i,j) ==1
           [StegoW(i,j),m]= PVD_Shiao(Cover(i,j),P(i,j),k,secret(index:end));
           index=index+m;
           c=c+m;
       end 
   end
end


figure; imshow(uint8(StegoB));
figure; imshow(uint8(StegoW));
fprintf('StegoBPSNR   %8.4f\n', psnr(uint8(Cover), uint8(StegoB)));
fprintf('StegoWPSNR   %8.4f\n', psnr(uint8(Cover), uint8(StegoW)));
fprintf('Payload%8.4f\n', c / (2*(rows * cols)));