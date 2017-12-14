function sessionObjectDef(dimension, measure) {
  const sessionObject = {
    qInfo: {
      qType: 'picasso-barchart',
    },
    qHyperCubeDef: {
      qDimensions: [{
        qDef: {
          qFieldDefs: [dimension],
          qLabel: dimension,
          qSortCriterias: [{
            qSortByAscii: 1,
          }],
        },
      }],
      qInterColumnSortOrder: [1, 0],
      qInitialDataFetch: [{
        qTop: 0,
        qHeight: 20,
        qLeft: 0,
        qWidth: 17,
      }],
      qSuppressZero: false,
      qSuppressMissing: true,
    },
  };

  if (measure) {
    sessionObject.qHyperCubeDef.qMeasures = [{
      qDef: {
        qDef: `"${measure}"`,
        qLabel: 'Anything',
      },
      qSortBy: {
        qSortByNumeric: -1,
      },
    }];
  }

  return sessionObject;
}

exports.getScenario = async (session) => {
  const app = await session.getActiveDoc();

  await app.createSessionObject(sessionObjectDef('Manufacturer Code Name', 'Count(Drug_caseID)')).then((x) => { x.getLayout(); });
  await app.createSessionObject(sessionObjectDef('Gender')).then((x) => { x.getLayout(); });
  await app.createSessionObject(sessionObjectDef('Patient Weight Group')).then((x) => { x.getLayout(); });
  await app.createSessionObject(sessionObjectDef('Country')).then((x) => { x.getLayout(); });
  await app.createSessionObject(sessionObjectDef('Drug Dose Form')).then((x) => { x.getLayout(); });
  await app.createSessionObject(sessionObjectDef('Medical Description Reaction', 'Count(Demographic_Caseid)')).then((x) => { x.getLayout(); });
  await app.createSessionObject(sessionObjectDef('Patient Event Outcome', 'Count(Demographic_Caseid)')).then((x) => { x.getLayout(); });
  await app.createSessionObject(sessionObjectDef('Medical Description Drug Use', 'Count(Demographic_Caseid)')).then((x) => { x.getLayout(); });
  await app.createSessionObject(sessionObjectDef('Reaction Therapy Stop', 'Count(Demographic_Caseid)')).then((x) => { x.getLayout(); });
  await app.createSessionObject(sessionObjectDef('Manufacturer Code Name', 'Count(Drug_caseID)')).then((x) => { x.getLayout(); });
  await app.createSessionObject(sessionObjectDef('Reaction Therapy Stop', 'Count(Demographic_Caseid)')).then((x) => { x.getLayout(); });
  await app.createSessionObject(sessionObjectDef('Patient Age Group', 'Count({<[Drug Role Event] = {\'Primary Suspect Drug\'},[Medical Description Reaction] = {\'Death\'} >}Demographic_Caseid)')).then((x) => { x.getLayout(); });
};
