FasdUAS 1.101.10   ��   ��    k             l     ��  ��    + % Created by Charles Laine on 12/6/17.     � 	 	 J   C r e a t e d   b y   C h a r l e s   L a i n e   o n   1 2 / 6 / 1 7 .   
  
 l     ��  ��    ; 5 Copyright � 2017 Charles Laine. All rights reserved.     �   j   C o p y r i g h t   �   2 0 1 7   C h a r l e s   L a i n e .   A l l   r i g h t s   r e s e r v e d .      l     ��������  ��  ��        l     ��  ��    N H This script fetches the list of tabs in the frontmost Safari window and     �   �   T h i s   s c r i p t   f e t c h e s   t h e   l i s t   o f   t a b s   i n   t h e   f r o n t m o s t   S a f a r i   w i n d o w   a n d      l     ��  ��    ( " returns a JSON array of strings.      �   D   r e t u r n s   a   J S O N   a r r a y   o f   s t r i n g s .        l     ��������  ��  ��     ��  l    l ����  O     l     k    k ! !  " # " r     $ % $ m     & & � ' '  [ % o      ���� 0 jsontabs jsonTabs #  ( ) ( Z    c * +���� * ?    , - , n     . / . m    ��
�� 
nmbr / 2   ��
�� 
cwin - m    ����   + k    _ 0 0  1 2 1 r     3 4 3 n     5 6 5 2    ��
�� 
bTab 6 4   �� 7
�� 
cwin 7 m    ����  4 o      ���� 0 tabslist tabsList 2  8 9 8 r     : ; : m    ����   ; o      ���� 0 tabcount tabCount 9  <�� < X    _ =�� > = k   / Z ? ?  @ A @ r   / 4 B C B [   / 2 D E D o   / 0���� 0 tabcount tabCount E m   0 1����  C o      ���� 0 tabcount tabCount A  F G F Z   5 D H I���� H ?  5 8 J K J o   5 6���� 0 tabcount tabCount K m   6 7����  I r   ; @ L M L b   ; > N O N o   ; <���� 0 jsontabs jsonTabs O m   < = P P � Q Q  , M o      ���� 0 jsontabs jsonTabs��  ��   G  R S R r   E R T U T b   E N V W V b   E L X Y X l  E F Z���� Z m   E F [ [ � \ \  "��  ��   Y l  F K ]���� ] c   F K ^ _ ^ n   F I ` a ` 1   G I��
�� 
pnam a o   F G���� 0 t   _ m   I J��
�� 
TEXT��  ��   W l  L M b���� b m   L M c c � d d  "��  ��   U o      ���� 0 quotedtabname quotedTabName S  e�� e r   S Z f g f b   S X h i h o   S T���� 0 jsontabs jsonTabs i o   T W���� 0 quotedtabname quotedTabName g o      ���� 0 jsontabs jsonTabs��  �� 0 t   > o   " #���� 0 tabslist tabsList��  ��  ��   )  j�� j r   d k k l k b   d i m n m o   d e���� 0 jsontabs jsonTabs n m   e h o o � p p  ] l o      ���� 0 jsontabs jsonTabs��     m      q q�                                                                                  sfri  alis    �  El Capitan from the AppSt#2�s�H+   �m{
Safari.app                                                      ��&��        ����  	                Applications    �sj:      �'     �m{  4El Capitan from the AppSt#2:Applications: Safari.app   
 S a f a r i . a p p  N & E l   C a p i t a n   f r o m   t h e   A p p S t o r e   ( 1 0 . 1 1 . 1 )  Applications/Safari.app   / ��  ��  ��  ��       �� r s��   r ��
�� .aevtoappnull  �   � **** s �� t���� u v��
�� .aevtoappnull  �   � **** t k     l w w  ����  ��  ��   u ���� 0 t   v  q &������������������ P [���� c�� o�� 0 jsontabs jsonTabs
�� 
cwin
�� 
nmbr
�� 
bTab�� 0 tabslist tabsList�� 0 tabcount tabCount
�� 
kocl
�� 
cobj
�� .corecnte****       ****
�� 
pnam
�� 
TEXT�� 0 quotedtabname quotedTabName�� m� i�E�O*�-�,j R*�k/�-E�OjE�O ?�[��l 
kh  �kE�O�k 
��%E�Y hO��,�&%�%E` O�_ %E�[OY��Y hO�a %E�Uascr  ��ޭ