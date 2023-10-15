import 'dart:io';

void sortFileSystemEntities(List<FileSystemEntity> entities) {
  entities.sort((entity1, entity2) {
    if (entity1 is Directory) {
      if (entity2 is Directory) {
        return entity1.path.compareTo(entity2.path);
      } else {
        return -1;
      }
    } else if (entity1 is File) {
      if (entity2 is File) {
        return entity1.path.compareTo(entity2.path);
      } else {
        return 1;
      }
    } else {
      return 1;
    }
  });
}
