
abstract final class CropImageMapper {
  static const Map<String, String> _images = {
    'Jagung': 'https://images.unsplash.com/photo-1649251037465-72c9d378acb6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
    'Padi': 'https://images.unsplash.com/photo-1655903724829-37b3cd3d4ab9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
    'Singkong': 'https://images.unsplash.com/photo-1710425417427-fee66167fa35?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
    'Kedelai': 'https://images.unsplash.com/photo-1758158329346-bed873fb6d9a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
    'Kacang Tanah': 'https://images.unsplash.com/photo-1703542136049-dd9df98bd648?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
    'Ubi Jalar': 'https://images.unsplash.com/photo-1741112480266-62def497fa27?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
    'Kangkung': 'https://images.unsplash.com/photo-1767334573903-f280cb211993?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
    'Bayam': 'https://images.unsplash.com/photo-1746258170547-35c35a8f9c9e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
    'Sorgum': 'https://images.unsplash.com/photo-1758356860542-a2df92aad294?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
    'Gandum': 'https://images.unsplash.com/photo-1657626625832-2c0851cdaa9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
  };

  static String? urlFor(String cropName) => _images[cropName];
}
