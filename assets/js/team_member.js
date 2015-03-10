(function() {

  var midasURL = MIDAS.url + '/api/user/profile' +
        '?where={"username":"' + MEMBER.email + '"}' +
        '&access_token=' + MIDAS.token,
      member = MEMBER;

  // Simplify team member data (could be done in yaml files instead)
  member.skills = _.union(member.languages, member.technologies);
  member.interests = member.specialties;
  delete member.languages;
  delete member.technologies;
  delete member.specialties;

  // Load data from Midas
  $.getJSON(midasURL).always(loadMidas);

  function loadMidas(data) {

    // If the user has a Midas profile,
    // extend member data with Midas profile data
    if (data.length) {
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
    }

    // Render templates
    _(['skills', 'interests']).each(function(set) {
      if (!member[set].length) return;
      var selector = '.template-' + set,
          compiled = _.template($(selector).html());
      $(selector).replaceWith(compiled(member));
    });

  }

})();
