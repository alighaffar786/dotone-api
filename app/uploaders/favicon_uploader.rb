class FaviconUploader < ImageUploader
  version :apple_icon_57x57 do
    process resize_to_fill: [57, 57]
  end

  version :apple_icon_60x60 do
    process resize_to_fill: [60, 60]
  end

  version :apple_icon_72x72 do
    process resize_to_fill: [72, 72]
  end
  version :apple_icon_76x76 do
    process resize_to_fill: [76, 76]
  end
  version :apple_icon_114x114 do
    process resize_to_fill: [114, 114]
  end
  version :apple_icon_120x120 do
    process resize_to_fill: [120, 120]
  end
  version :apple_icon_144x144 do
    process resize_to_fill: [144, 144]
  end
  version :apple_icon_152x152 do
    process resize_to_fill: [152, 152]
  end
  version :apple_icon_180x180 do
    process resize_to_fill: [180, 180]
  end
  version :android_icon_192x192 do
    process resize_to_fill: [192, 192]
  end
  version :android_icon_144x144 do
    process resize_to_fill: [144, 144]
  end
  version :android_icon_96x96 do
    process resize_to_fill: [96, 96]
  end
  version :android_icon_72x72 do
    process resize_to_fill: [72, 72]
  end
  version :android_icon_48x48 do
    process resize_to_fill: [48, 48]
  end
  version :android_icon_36x36 do
    process resize_to_fill: [36, 36]
  end
  version :favicon_32x32 do
    process resize_to_fill: [32, 32]
  end
  version :favicon_96x96 do
    process resize_to_fill: [96, 96]
  end
  version :favicon_16x16 do
    process resize_to_fill: [16, 16]
  end
  version :ms_icon_144x144 do
    process resize_to_fill: [144, 144]
  end

  def extension_white_list
    super + ['ico']
  end
end
