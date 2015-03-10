(function() {

  var midasURL = MIDAS.url + '/api/user/profile' +
        '?where={"username":"' + JSON.stringify(MEMBERS) + '"}' +
        '&access_token=' + MIDAS.token,
      members = MEMBERS;

  // Load data from Midas
  $.getJSON(midasURL).always(loadMidas);

  function loadMidas(midas) {
    _(members).each(function(member) {
      var data = [_(midas).where({ username: member.email })];

      // Simplify team member data (could be done in yaml files instead)
      member.skills = _.union(member.languages, member.technologies);
      member.interests = member.specialties;
      delete member.languages;
      delete member.technologies;
      delete member.specialties;

      // If the user has no Midas data, stop here:
      if (!data) return;

      // Extend member data with Midas profile data
      var skills = _(data[0].tags).chain()
            .pluck('tag')
            .where({ type: 'skill' })
            .pluck('name')
            .invoke('trim')
            .invoke('toLowerCase').value(),
          interests = _(data[0].tags).chain()
            .pluck('tag')
            .where({ type: 'topic' })
            .pluck('name')
            .invoke('trim')
            .invoke('toLowerCase').value();
      member.skills = _.union(member.skills, skills);
      member.interests = _.union(member.interests, interests);

    });
    // Roll up
    members.skills = _(members).chain()
      .pluck('skills')
      .flatten()
      .invoke('trim')
      .invoke('toLowerCase')
      .uniq()
      .sortBy().value();

    // Render templates
    var selector = '.template-skills',
        compiled = _.template($(selector).html());
    $(selector).replaceWith(compiled(members));

  }

})();
