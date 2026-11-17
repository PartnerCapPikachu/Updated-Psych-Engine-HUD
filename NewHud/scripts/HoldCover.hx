import flixel.group.FlxTypedSpriteGroup;
import objects.NoteSplash.PixelSplashShaderRef;
using StringTools;

Paths.image('holdCover');

var grpNoteCovers:FlxTypedSpriteGroup<FlxSprite> = new FlxTypedSpriteGroup();
function onCreatePost()
{
  game.noteGroup.insert(game.noteGroup.members.indexOf(game.grpNoteSplashes), grpNoteCovers);

  game.notes.memberRemoved.add(function(note:Note)
  {
    if (note.isSustainNote || note.parent != null)
    {
      var cover = note.parent.extraData.get('cover');
      if (cover != null && note.animation.name.endsWith('end') && cover.animation.name != 'end')
      {
        cover.kill();
        note.parent.extraData.set('cover', null);
      }
    }
  });
}

function spawnCover(note:Note, strum:StrumNote)
{
  //no support for the other types yet
  if (ClientPrefs.data.noteSkin.toLowerCase() != 'default')
  {
    return;
  }

  var cover = new FlxSprite(); //recycle doesn't work properly sometimes i guess?
  cover.antialiasing = ClientPrefs.data.antialiasing;
  cover.frames = Paths.getSparrowAtlas('holdCover');
  cover.animation.addByPrefix('start', 'start', 24, false);
  cover.animation.addByPrefix('hold', 'hold', 24, true);
  cover.animation.addByPrefix('end', 'end', 24, false);

  cover.animation.play('start');
  cover.offset.set(107.5, 100);

  if (strum != null)
  {
    cover.x = strum.x;
    cover.y = strum.y;
    cover.visible = strum.visible;
    cover.alpha = strum.alpha;
  }

  //todo: note splashes use new shader?
  if (note != null)
  {
    var tempShader = Note.globalRgbShaders[note.noteData % Note.colArray.length];
    var rgbShader = game.createRuntimeShader('PixelSplashShaderRef');
    rgbShader.setFloatArray('r', tempShader.shader.r.value);
    rgbShader.setFloatArray('g', tempShader.shader.g.value);
    rgbShader.setFloatArray('b', tempShader.shader.b.value);
    rgbShader.setFloat('mult', tempShader.shader.mult.value[0]);
    rgbShader.setFloatArray('uBlocksize', [PlayState.isPixelStage ? PlayState.daPixelZoom : 1, PlayState.isPixelStage ? PlayState.daPixelZoom : 1]);
    cover.shader = rgbShader;
    tempShader = null;

    note.parent.extraData.set('cover', cover);
  }

  grpNoteSplashes.add(cover);

  cover.animation.finishCallback = animName -> switch (animName)
  {
    case 'start':
      cover.animation.play('hold', true);

    case 'hold':
      if (strum != null && strum.player == 1)
        cover.animation.play('end', true);
      else
        cover.kill();

    case 'end':
      cover.kill();
  }
}

function processNote(note:Note)
{
  if (!note.isSustainNote || note.parent == null)
  {
    return;
  }

  if (note.parent.extraData.get('cover') == null)
  {
    spawnCover(note, (note.mustPress ? game.playerStrums : game.opponentStrums).members[note.noteData]);
  }

  var cover = note.parent.extraData.get('cover');
  if (cover != null && note.animation.name.endsWith('end'))
  {
    if (cover.animation.name == 'start' || note.animation.name.endsWith('end'))
      cover.animation.play('hold', true);
    cover.animation.curAnim.finish();
  }
}

function goodNoteHit(note:Note)
{
  processNote(note);
}
function opponentNoteHit(note:Note)
{
  processNote(note);
}

function noteMiss(note:Note)
{
  var cover;
  if (!guitarHeroSustains)
  {
    cover = note.parent.extraData.get('cover');
    if (note.isSustainNote && note.parent != null && cover != null &&
      (note.animation.name.endsWith('end') || !controls.pressed(keysArray[note.noteData])))
    {
      cover.kill();
      note.parent.extraData.set('cover', null);
    }
  }
  else
  {
    if (note.parent == null)
    {
      cover = note.extraData.get('cover');
      if (note.tail.length != 0 && cover != null)
        cover.kill();
    }
    else if (note.isSustainNote && note.parent.wasGoodHit && (cover = note.parent.extraData.get('cover')) != null)
    {
      cover.kill();
    }
  }
}

function handleCovers(note:Note)
{
  if (note.isSustainNote || note.parent != null)
  {
    return;
  }

  var cover = note.extraData.get('cover');
  if (cover == null)
  {
    return;
  }

  var strum = (note.mustPress ? game.playerStrums : game.opponentStrums).members[note.noteData];
  if (strum == null)
  {
    return;
  }

  cover.x = strum.x;
  cover.y = strum.y;
  cover.visible = strum.visible;
  cover.alpha = strum.alpha;
}

function onUpdatePost(elasped:Float)
{
  game.notes.forEachAlive(handleCovers);
}