git = require '../../lib/git'
{repo} = require '../fixtures'
TagCreateView = require '../../lib/views/tag-create-view'

describe "TagCreateView", ->
  describe "when there are two tags", ->
    beforeEach ->
      @view = new TagCreateView(repo)

    it "displays inputs for tag name and message", ->
      expect(@view.tagName).toBeDefined()
      expect(@view.tagMessage).toBeDefined()

    it "creates a tag with the given name and message", ->
      spyOn(git, 'cmd').andReturn Promise.resolve 0
      cwd = repo.getWorkingDirectory()
      @view.tagName.setText 'tag1'
      @view.tagMessage.setText 'tag1 message'
      @view.find('.gp-confirm-button').click()
      expect(git.cmd).toHaveBeenCalledWith ['tag', '-a', 'tag1', '-m', 'tag1 message'], {cwd}

    it "creates a signed tag with the given name and message", ->
      atom.config.set('git-plus.tags.signTags', true)
      spyOn(git, 'cmd').andReturn Promise.resolve 0
      cwd = repo.getWorkingDirectory()
      @view.tagName.setText 'tag2'
      @view.tagMessage.setText 'tag2 message'
      @view.find('.gp-confirm-button').click()
      expect(git.cmd).toHaveBeenCalledWith ['tag', '-s', 'tag2', '-m', 'tag2 message'], {cwd}
