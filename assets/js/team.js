(function() {

  var midasURL = MIDAS.url + '/api/user/profile' +
        '?where={"username":' + JSON.stringify(_(MEMBERS).pluck('email')) + '}' +
        '&access_token=' + MIDAS.token,
      members = MEMBERS,
      category = CATEGORY,
      filter = decodeURIComponent(window.location.search.slice(1))
        .trim()
        .toLowerCase();

  // Load data from Midas
  $.getJSON(midasURL).always(loadMidas);

  function loadMidas(midas) {
    _(members).each(function(member) {
      var profile = _(midas).findWhere({ username: member.email });

      // Simplify team member data (could be done in yaml files instead)
      member.skills = _.union(member.languages, member.technologies);
      member.interests = member.specialties;
      delete member.languages;
      delete member.technologies;
      delete member.specialties;

      // Extend member data with Midas profile data
      if (profile) {
        var skills = _(profile.tags).chain()
              .pluck('tag')
              .where({ type: 'skill' })
              .pluck('name').value(),
            interests = _(profile.tags).chain()
              .pluck('tag')
              .where({ type: 'topic' })
              .pluck('name').value();
      }

      // Join and clean up lists
      member.skills = _.chain()
        .union(member.skills, skills)
        .invoke('trim')
        .invoke('toLowerCase')
        .uniq().value();

      member.interests = _.chain().
        union(member.interests, interests)
        .invoke('trim')
        .invoke('toLowerCase')
        .uniq().value();
    });

    // Set up template based on filter
    if (category === 'profile') {

      // Render templates
      _(['skills', 'interests']).each(function(set) {
        if (!members[0][set].length) return;
        var selector = '.template-' + set,
            compiled = _.template($(selector).html());
        $(selector).replaceWith(compiled(members[0]));
      });

    } else if (filter) {

      // Filter users
      members.members = _(members).filter(function(member) {
        var items = _(member[category]).chain()
          .invoke('trim')
          .invoke('toLowerCase').value();
        return (items.indexOf(filter) >= 0);
      });

      // Render template
      var selector = '.template-members',
          compiled = _.template($(selector).html());
      $(selector).replaceWith(compiled(members));
      $('h1').text(category + ': ' + filter);

    } else {

      // Aggregate skills list
      members[category] = _(members).chain()
        .pluck(category)
        .flatten()
        .uniq()
        .sortBy().value();

      // Render template
      var selector = '.template-items',
          compiled = _.template($(selector).html());
      $(selector).replaceWith(compiled(members));
      $('h1').text(category);

    }

  }

})();
