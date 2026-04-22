import '../services/music_service.dart';
import 'package:flutter/material.dart';

final List<Song> sampleQueue = [
  Song(
    id: '1',
    title: 'Essence',
    artist: 'Chad Crouch',
    fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/Chad%20Crouch%20-%20Essence.mp3',
    genre: 'Afrobeats',
    themeColor: const Color(0xFFE65100),
    isLiked: true,
  ),
  Song(
    id: '2',
    title: 'Falling For You',
    artist: 'Happy Refugees',
    fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/Happy%20Refugees%20-%20Falling%20For%20You.mp3',
    genre: 'R&B',
    themeColor: const Color(0xFF1565C0),
  ),
  Song(
    id: '3',
    title: 'The Weekend',
    artist: 'Krestovsky',
    fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/Krestovsky%20-%20The%20Weekend.mp3',
    genre: 'Pop',
    themeColor: const Color(0xFFB71C1C),
  ),
  Song(
    id: '4',
    title: 'Beautiful and Young',
    artist: 'Break The Bans',
    fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/Break%20The%20Bans%20-%20Beautiful%20and%20young.mp3',
    genre: 'Pop',
    themeColor: const Color(0xFF2E7D32),
  ),
  Song(
    id: '5',
    title: 'Fight Song',
    artist: 'Cletus Got Shot',
    fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/Cletus%20Got%20Shot%20-%20Fight%20Song.mp3',
    genre: 'Hip Hop',
    themeColor: const Color(0xFF4A148C),
  ),
  Song(
    id: '6',
    title: 'Humble',
    artist: 'Tep',
    fileUrl: 'https://qhtqkpjgxjzqcpyknebv.supabase.co/storage/v1/object/public/songs/Tep%20-%20humble.mp3',
    genre: 'Hip Hop',
    themeColor: const Color(0xFF00695C),
  ),
];