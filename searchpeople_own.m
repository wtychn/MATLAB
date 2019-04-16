clc
close all
clear
RGB=imread('testpeo.jpg');
RGB1=imcrop(RGB,[1500,500,2200,2200]);
BW=im2bw(RGB1,0.3);
tohandle=~BW;
subplot(2,2,1);
imshow(RGB);
title('ԭͼ');
subplot(2,2,2);
imshow(RGB1);
title('�ü�');
subplot(2,2,3);
imshow(BW);
title('��ֵ��');

%������̬ѧ������ʴ�����͡��׶����
erodeElement = strel('square', 3) ;
dilateElement=strel('square', 8) ;
tohandle=imerode(tohandle,erodeElement);
tohandle=imerode(tohandle,erodeElement);
tohandle=imdilate(tohandle,dilateElement);
tohandle=imdilate(tohandle,dilateElement);
tohandle=imfill(tohandle,'holes');
subplot(2,2,4);
imshow(tohandle);
title('��ɫ��ת����̬ѧ����');

%��ȡ�����'basic'���ԣ� 'Area', 'Centroid', and 'BoundingBox' 
figure('name','������'),
stats = regionprops(tohandle, 'basic');
rects=cat(1,stats.BoundingBox);
f_areas=find([stats.Area]>80000);
f_rects=rects(f_areas, :);
%��λ��������
imshow(RGB1);
hold on
for i = 1:size(f_rects, 1)
    rectangle('Position',f_rects(i,:),'LineWidth',2,'LineStyle','--','EdgeColor','r'),
end
hold off