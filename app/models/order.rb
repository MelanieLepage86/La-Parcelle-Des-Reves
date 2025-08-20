class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :artworks, through: :order_items

  enum status: {
    pending: 'pending',
    valide: 'valide',
    en_cours: 'en_cours',
    expedie: 'expedie',
    recue: 'recue',
    retour: 'retour',
    remboursee: 'remboursee',
    termine: 'termine'
  }

  def status_label
    {
      "pending" => "En attente",
      "valide" => "Validée",
      "en_cours" => "En cours",
      "expedie" => "Expédiée",
      "recue" => "Reçue",
      "retour" => "Retour",
      "remboursee" => "Remboursée",
      "termine" => "Terminé"
    }[status] || status.humanize
  end
end
