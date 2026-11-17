import flixel.math.FlxRect;

function sustainReduce(note:Note)
{
  if (!note.isSustainNote || note.parent == null)
  {
    return;
  }

  var strum = (note.mustPress ? game.playerStrums : game.opponentStrums).members[note.noteData];
  var centerTarget = strum;
  if (strum == null || (!note.parent.wasGoodHit && !note.parent.missed))
  {
    centerTarget = note.parent;
  }

  if (note.mustPress && centerTarget == strum && !controls.pressed(keysArray[note.noteData]) || note.missed)
  {
    if (!cpuControlled)
      return;
  }

  var clipRect = note.clipRect;
  if (clipRect == null)
  {
    clipRect = new FlxRect(0, 0, note.frameWidth, note.frameHeight);
  }

  var clipped:Bool = false;
  var center:Float = centerTarget.y + Note.swagWidth / 2;
  if (strum.downScroll)
  {
    if (note.y - (note.offset.y - note.offsetY) * note.scale.y + note.height >= center)
    {
      clipRect.height = (center - note.y) / note.scale.y;
      clipRect.y = note.frameHeight - clipRect.height;
      clipped = true;
    }
  }
  else if (note.y + (note.offset.y + note.offsetY) * note.scale.y <= center)
  {
    clipRect.y = (center - note.y) / note.scale.y;
    clipRect.height = note.frameHeight - clipRect.y;
    clipped = true;
  }

  if (!clipped)
  {
    clipRect.height = note.frameHeight;
    clipRect.y = 0;
  }

  note.clipRect = clipRect;
}

function onUpdatePost(elapsed:Float)
{
  game.notes.forEachAlive(sustainReduce);
}