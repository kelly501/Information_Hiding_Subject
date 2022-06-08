pkg load image; pkg load image;
clc; clear all;
Img = imread('4.2.04.tiff');
Cover = double(rgb2gray(Img));
[rows cols] = size(Cover);
Stego = zeros(rows, cols);

Secret = randi([0 1], 1, rows * cols * 4);

k = 3;
New_Lengs = [0 2 1;3 7 2;8 14 2;15 23 3;24 34 3;35 47 3;48 62 3;63 79 4;80 98 4;99 119 4;120 142 4;143 167 4;168 194 4;195 223 4;224 254 4;];


count = 1;
for i = 1 : 3 : rows * cols - 2
  G = [Cover(i) Cover(i + 1) Cover(i + 2)];
  s = 0;
  for j = 1:k
    s += Secret(count) * 2 ^ (k-j);
    count += 1;
  end
  Stego(i+1)=Cover(i+1)-mod(Cover(i+1),2^k)+s;
  d=Stego(i+1)-Cover(i+1);
    if d<2^k && d>2^(k-1)
      if Stego(i+1)>=2^k
        Stego(i+1)=Stego(i+1)-2^k;
      end
    end
    if d>-2^k && d<-2^(k-1)
      if Stego(i+1)<256-2^k
        Stego(i+1)=Stego(i+1)+2^k;
      end
    end

  d1 = abs(G(1) - G(2));
  r = 0; l = 0; m = 0;
  for j = 1 : 15
    if d1 >= New_Lengs(j, 1) && d1 <= New_Lengs(j, 2)
      r = j;
      l = floor(log2(2*r+1));
      m = New_Lengs(r,3);
      break;
    end
  end
  
    s = 0; p=count;
    for j = 1 : (m+1)
      s += Secret(p) * 2 ^ (j - 1);
      p += 1;
    end
  if (mod((r^2-1),2^(m+1)))<=s && s<=(mod((r^2+2*r-2^l-1),2^(m+1)))
    new_d1= (r^2-1)- mod((r^2-1),2^(m+1))+s
    if abs(G(2) - new_d1 - G(1)) <= abs(G(2) + new_d1 - G(1))
      G(1) = G(2) - new_d1;
    else
      G(1) = G(2) + new_d1;
    end
    Stego(i) = G(1);
    count=p;
  elseif (mod((r^2+2^l-1),2^(m+1)))<=s && s<=(mod((r^2+2*r-1),2^(m+1)))
    new_d1=(r^2+2^l-1)-mod((r^2+2^l-1),2^(m+1))+s;
    if abs(G(2) - new_d1 - G(1)) <= abs(G(2) + new_d1 - G(1))
      G(1) = G(2) - new_d1;
    else
      G(1) = G(2) + new_d1;
    end
    Stego(i) = G(1);
    count=p;
  else
    s = 0; p=count;
    for j = 1 : m
      s += Secret(p) * 2 ^ (j - 1);
      p += 1;
    end
    if (mod((r^2+2*r-2^l),2^m))<=s && s<=(mod((r^2+2^l-2),2^m))
      new_d1=(r^2+2*r-2^l)-mod((r^2+2*r-2^l),2^m)+s;
      if abs(G(2) - new_d1 - G(1)) <= abs(G(2) + new_d1 - G(1))
      G(1) = G(2) - new_d1;
    else
      G(1) = G(2) + new_d1;
    end
    Stego(i) = G(1);
    count=p;
  end
  
  
  d2 = abs(G(3) - G(2));
  r = 0; l = 0; m = 0;
  for j = 1 : 15
    if d2 >= New_Lengs(j, 1) && d2 <= New_Lengs(j, 2)
      r = j;
      l = floor(log2(2*r+1));
      m = New_Lengs(r,3);      
      break;
    end
  end
  
  s = 0; p=count;
  for j = 1 : (m+1)
    s += Secret(p) * 2 ^ (j - 1);
    p += 1;
  end
  
  if (mod((r^2-1),2^(m+1)))<=s && s<=(mod((r^2+2*r-2^l-1),2^(m+1)))
    new_d2= (r^2-1)- mod((r^2-1),2^(m+1))+s
    if abs(G(2) - new_d2 - G(3)) <= abs(G(2) + new_d2 - G(3))
      G(3) = G(2) - new_d2;
    else
      G(3) = G(2) + new_d2;
    end
    Stego(i+2) = G(3);
    count=p;
  elseif (mod((r^2+2^l-1),2^(m+1)))<=s && s<=(mod((r^2+2*r-1),2^(m+1)))
    new_d2=(r^2+2^l-1)-mod((r^2+2^l-1),2^(m+1))+s;
    if abs(G(2) - new_d2 - G(3)) <= abs(G(2) + new_d2 - G(3))
      G(3) = G(2) - new_d2;
    else
      G(3) = G(2) + new_d2;
    end
    Stego(i+2) = G(3);
    count=p;
  else
    s = 0; p=count;
    for j = 1 : m
      s += Secret(p) * 2 ^ (j - 1);
      p += 1;
    end
    if (mod((r^2+2*r-2^l),2^m))<=s && s<=(mod((r^2+2^l-2),2^m))
      new_d2=(r^2+2*r-2^l)-mod((r^2+2*r-2^l),2^m)+s;
      if abs(G(2) - new_d2 - G(3)) <= abs(G(2) + new_d2 - G(3))
      G(3) = G(2) - new_d2;
      else
      G(3) = G(2) + new_d2;
      end
    Stego(i+2) = G(3);
    count=p;
   end
  end
 end
end
figure; imshow(uint8(Cover));
figure; imshow(uint8(Stego));
fprintf('PSNR=%8.4f\n', psnr(uint8(Cover), uint8(Stego)));
fprintf('Payload=%d\n', count);
