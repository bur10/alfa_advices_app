class Vote {
  static List<int> vote(int alpha, int beta, int userVote, String voting) {
    int newVote;
    int newAlpha = alpha;
    int newBeta = beta;

    if (voting == 'VoteUp') {
      switch (userVote) {
        case 0:
          newAlpha += 1;
          newVote = 2;
          break;
        case 1:
          newAlpha += 1;
          newBeta -= 1;
          newVote = 2;
          break;
        case 2:
          newAlpha -= 1;
          newVote = 0;
          break;
      }
    } else {
      switch (userVote) {
        case 0:
          newBeta += 1;
          newVote = 1;
          break;
        case 1:
          newBeta -= 1;
          newVote = 0;
          break;
        case 2:
          newBeta += 1;
          newAlpha -= 1;
          newVote = 1;
          break;
      }
    }

    List<int> newValues = [newVote, newAlpha, newBeta];

    return newValues;
  }
}
