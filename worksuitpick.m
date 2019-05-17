clc
close all
clear
RGB=imread('worksuit.jpg');%��ȡ��ͼ
[m,n,d]=size(RGB);
RB=uint8(RGB);%תΪuint8�������ͣ�����ͼ������
level_b=15;%������ֵ
level_r=15;
figure(1);
subplot(2,3,1);imshow(RGB);title('ԭͼ');%��ʾԭͼ

%ԭͼ��ֵ��
BW=im2bw(RGB,0.3);
subplot(2,3,2);imshow(BW);title('��ֵ��');

%������̬ѧ������ʴ�����͡��׶����
tohandle=~BW;
for l=1:300
    tohandle(l,:)=0;
end
tohandle=bwareaopen(tohandle,10000);
subplot(2,3,3);
imshow(tohandle);
title('��ɫ��ת');
erodeElement = strel('square', 4) ;
dilateElement=strel('square', 8) ;
tobox=imerode(tohandle,erodeElement);
tobox=imdilate(tobox,dilateElement);
tobox=imfill(tobox,'holes');
tobox=bwareaopen(tobox,10000);
subplot(2,3,4);
imshow(tobox);
title('��̬ѧ����');

%��ȡ����������������ֵ�ı�Ϊ��ɫ
for i=1:m
    for j=1:n
        if((RGB(i,j,3)-RGB(i,j,1)>level_b)&&(RGB(i,j,3)-RGB(i,j,2)>level_b))
            RB(i,j,1)=RGB(i,j,1);
            RB(i,j,2)=RGB(i,j,2);
            RB(i,j,3)=RGB(i,j,3);
        else RB(i,j,1)=255;
            RB(i,j,2)=255;
            RB(i,j,3)=255;
        end
    end
end
subplot(2,3,5);imshow(RB);title('��ȡ��������');%��ʾ��ȡ���������ͼ

%��ֵ��
BW_b=im2bw(RB,0.5);
bw_b_toshow=~BW_b;
for l=1:300
    bw_b_toshow(l,:)=0;
end
bw_b_toshow=bwareaopen(bw_b_toshow,1000);
subplot(2,3,6);imshow(bw_b_toshow);title('��������ֵ��ͼ��');

%��ȡ�����'basic'���ԣ� 'Area', 'Centroid', and 'BoundingBox' 
stats = regionprops(tobox, 'basic');
rects=cat(1,stats.BoundingBox);
f_areas=find([stats.Area]>30000);%ɸѡ����������ֵ����
f_rects=rects(f_areas, :);
figure('name','������'),
imshow(RGB);
hold on
%����
count_blue=zeros(1,size(f_rects, 1));
count_peoarea=zeros(1,size(f_rects, 1));
count=zeros(1,size(f_rects, 1));
for i = 1:size(f_rects, 1)
    c=uint16(f_rects(i,:));
    for p=c(2):(c(2)+c(4))
         for q=c(1):(c(1)+c(3))
             if(tobox(p,q)==1)
                count_peoarea(i)=count_peoarea(i)+1;
             end
             if(bw_b_toshow(p,q)==1)
                count_blue(i)=count_blue(i)+1;
             end
         end
    end
    if(count_blue(i)/count_peoarea(i)>0.8)  %���·�����ռ����������������Ҫ��
        rectangle('Position',f_rects(i,:),'LineWidth',2,'LineStyle','--','EdgeColor','g');
        text(f_rects(i,1),f_rects(i,2)-40,  '����������Ҫ��','color','green');
    else
        rectangle('Position',f_rects(i,:),'LineWidth',2,'LineStyle','--','EdgeColor','r');
        text(f_rects(i,1),f_rects(i,2)-40,  '������������Ҫ��','color','red');
    end
end
count_blue
count_peoarea
hold off 